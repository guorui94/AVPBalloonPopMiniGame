//
//  ImmersiveView.swift
//  NYP Open House
//
//  Created by Amelia on 8/7/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct FlippedComponent: Component {}
struct IsFlippingBackComponent: Component {}

struct MemoryGameImmersive: View {
    @Environment(AppModel.self) var appModel
    @State private var predicate = QueryPredicate<Entity>.has(ModelComponent.self)
    @State private var worldAnchor = AnchorEntity(world: [0, 0, 0])
    @State private var currentGameMode = GameModes.easy
    @State private var firstFlippedEntity: Entity? = nil
    @State private var firstFlippedImage: String = ""
    @State private var pendingFlipCount = 0
    @State private var flippedCount = 0
    @State private var cardsPairCount = 0
    @State private var moveToNextLevelSound: AudioFileResource?
    @State private var flipSuccess: AudioFileResource?
    @State private var overlayEntity: Entity?

    var body: some View {
        RealityView { content, attachments in
            worldAnchor.children.removeAll()
            let pose = appModel.pose
            await pose.startIfNeeded()
            try? await Task.sleep(for: .seconds(0.5))
            var spawnY: Float = 0.0
            var spawnZ: Float = 0.0
            if let deviceAnchor = pose.worldTracking.queryDeviceAnchor(
                atTimestamp: CACurrentMediaTime())
            {
                let transform = deviceAnchor.originFromAnchorTransform
                spawnY = transform.columns.3.y - 0.1
                spawnZ = transform.columns.3.z - 0.9
            }
            worldAnchor.position = [0, spawnY, spawnZ]
            
            if let immersiveContentEntity = try? await Entity(named: "ImageAnchorScene", in: realityKitContentBundle),
               let baseTile = immersiveContentEntity.findEntity(named: "Tile")
            {
                await createGameTiles(gameMode: currentGameMode, baseTile: baseTile, worldAnchor: worldAnchor)
                
                try? await Task.sleep(for: .milliseconds(400))
                content.add(worldAnchor)
                
                Task {
                    if let overlayTag = attachments.entity(for: "scoreOverlay") {
                        overlayTag.position = [-0.46, 0.7, -0.05]
                        overlayEntity = overlayTag
                        worldAnchor.addChild(overlayTag)
                    }
                }

            }
        } attachments: {
            Attachment(id: "scoreOverlay") {
                MemoryGameOverlay(currentGameMode: $currentGameMode)
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToEntity(where: predicate)
                .onEnded { value in
                    let entity = value.entity
                    guard
                        !entity.components.has(FlippedComponent.self),
                        !entity.components.has(IsFlippingBackComponent.self),
                        flippedCount < 2
                    else {
                        return
                    }

                    entity.components.set(FlippedComponent())
                    animateFlip(entity: entity)
                    flippedCount += 1
                    pendingFlipCount += 1
                    
                    let imagePair = entity.components[PairComponent.self]!.imageString
                    let pairScore = entity.components[ScoreComponent.self]!.score
                    let score = appModel.score
                    
                    if flippedCount == 1 {
                        firstFlippedEntity = entity
                        firstFlippedImage = imagePair
                    }
                    
                    Task {
                        try? await Task.sleep(for: .milliseconds(300))
                        pendingFlipCount -= 1
                        if flippedCount == 2 && pendingFlipCount == 0 {
                            if imagePair == firstFlippedImage {
                                entity.playAudio(flipSuccess!)
                                animateDisappear(entity: firstFlippedEntity!)
                                animateDisappear(entity: entity)
                                cardsPairCount += 1
                                score.flipScore += pairScore
                                
                                if cardsPairCount == currentGameMode.images.count / 2 {
                                    entity.playAudio(moveToNextLevelSound!)
                                    try? await Task.sleep(for: .seconds(1))
                                    if let next = nextMode(after: currentGameMode) {
                                        currentGameMode = next
                                        cardsPairCount = 0
                                        worldAnchor.children.removeAll()
                                        
                                        if let immersiveContentEntity = try? await Entity(named: "ImageAnchorScene", in: realityKitContentBundle),
                                           let baseTile = immersiveContentEntity.findEntity(named: "Tile") {
                                            await createGameTiles(gameMode: next, baseTile: baseTile, worldAnchor: worldAnchor)
                                        }
                                        if let overlay = overlayEntity {
                                            if currentGameMode == .challenging{
                                                overlay.position.x -= 0.06
                                                overlay.position.y += 0.05
                                            }
                                            worldAnchor.addChild(overlay)
                                        }

                                    }
                                }
                            } else {
                                if let first = firstFlippedEntity {
                                    shakeEntity(first)
                                }
                                shakeEntity(entity)
                                try? await Task.sleep(for: .milliseconds(400))
                                flipBackAllCards(in: worldAnchor)
                            }
                            flippedCount = 0
                            firstFlippedEntity = nil
                            firstFlippedImage = ""
                        }
                    }
                }
        )
        .task {
            if moveToNextLevelSound == nil && flipSuccess == nil {
                do {
                    moveToNextLevelSound = try await AudioFileResource(named: "MoveToNextLevel.mp3")
                    flipSuccess = try await AudioFileResource(named: "FlipSuccess.mp3")
                } catch {
                    print("Failed to load audio: \(error)")
                }
            }
        }
        .onChange(of: appModel.gameEnds){
            worldAnchor.children.removeAll()
        }
    }
    
    func createGameTiles(gameMode: GameModes, baseTile: Entity, worldAnchor: AnchorEntity) async {
        var images = gameMode.images
        images.shuffle()
        let rows = gameMode.rows
        let columns = gameMode.columns
        let spacing: Float = 0.18
        
        var tileIndex = 0
        
        for row in 0..<rows {
            for col in 0..<columns {
                if tileIndex >= images.count {
                    break
                }
                
                let imageName = images[tileIndex]
                tileIndex += 1
                
                let tileClone = baseTile.clone(recursive: true)
                
                guard var pairComponent = tileClone.components[PairComponent.self],
                      var scoreComponent = tileClone.components[ScoreComponent.self] else {
                    fatalError()
                }
                
                pairComponent.imageString = imageName
                tileClone.components.set(pairComponent)
                scoreComponent.score = gameMode.score
                tileClone.components.set(scoreComponent)
                
                guard var modelComponent = tileClone.components[ModelComponent.self],
                      var mat = modelComponent.materials.first as? ShaderGraphMaterial else {
                    fatalError()
                }
                
                do {
                    let texture = try await TextureResource(named: imageName)
                    try mat.setParameter(name: "FrontImage", value: .textureResource(texture))
                    modelComponent.materials[0] = mat
                    tileClone.components.set(modelComponent)
                } catch {
                    print("Error setting texture: \(error)")
                }
                
                let totalWidth = Float(columns - 1) * spacing
                let totalHeight = Float(rows - 1) * spacing
                let startX = -totalWidth / 2
                let startY = totalHeight / 2
                
                let x = startX + Float(col) * spacing
                let y = startY - Float(row) * spacing
                let z: Float = 0
                
                tileClone.position = [x, y, z]
                worldAnchor.addChild(tileClone)
            }
        }
        createGameModeText(gameMode, worldAnchor: worldAnchor)
        
    }

    func createGameModeText(_ currentGameMode: GameModes, worldAnchor: AnchorEntity) {
        let text = currentGameMode.modes
        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.015,
            font: .systemFont(ofSize: 0.18, weight: .heavy),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        
        let textMaterial = UnlitMaterial(color: currentGameMode.color)
        let textEntity = ModelEntity(mesh: mesh, materials: [textMaterial])
        textEntity.scale = [0.3, 0.3, 0.3]
        
        let shadowMaterial = UnlitMaterial(color: currentGameMode.shadowColor)
        let shadowEntity = ModelEntity(mesh: mesh, materials: [shadowMaterial])
        shadowEntity.scale = [1.0, 1.0, 1.0]
        shadowEntity.position = [0.012, -0.012, -0.002]
        textEntity.addChild(shadowEntity)
        
        
        if let bounds = textEntity.model?.mesh.bounds {
            let centerOffset = bounds.center.x * textEntity.scale.x
            textEntity.position.x -= centerOffset
        }

        let totalHeight = Float(currentGameMode.rows) * 0.18
        textEntity.position.y = totalHeight / 2  + 0.1
        textEntity.position.z = 0.0

        let originalY = textEntity.position.y
        let animationDuration = 3.0
        let floatAmplitude: Float = 0.02

        var frame = 0
        Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            frame += 1
            let time = Double(frame) / 60.0
            let cycle = (.pi * 2.0) / animationDuration
            let offset = Float(sin(time * cycle)) * floatAmplitude

            textEntity.position.y = originalY + offset
        }
        
        worldAnchor.addChild(textEntity)
    }


    func animateFlip(entity: Entity) {
        let newRotation = entity.transform.rotation * simd_quatf(angle: .pi, axis: [-1, 0, 0])
        var transform = entity.transform
        transform.rotation = newRotation
        entity.move(to: transform, relativeTo: entity.parent, duration: 0.3, timingFunction: .easeInOut)
    }
    
    func shakeEntity(_ entity: Entity, repeatCount: Int = 4, distance: Float = 0.01) {
        let originalPosition = entity.position

        for i in 0..<repeatCount {
            let delay = Double(i) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                var transform = entity.transform
                let direction: Float = (i % 2 == 0) ? 1 : -1
                transform.translation.x = originalPosition.x + direction * distance
                entity.move(to: transform, relativeTo: entity.parent, duration: 0.03, timingFunction: .easeInOut)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(repeatCount) * 0.05) {
            var transform = entity.transform
            transform.translation = originalPosition
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.05, timingFunction: .easeInOut)
        }
    }

    func flipBackAllCards(in worldAnchor: AnchorEntity) {
        for entity in worldAnchor.children {
            guard entity.components.has(FlippedComponent.self) else { continue }

            entity.components.set(IsFlippingBackComponent())

            let newRotation = entity.transform.rotation * simd_quatf(angle: .pi, axis: [-1, 0, 0])
            var transform = entity.transform
            transform.rotation = newRotation
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.5, timingFunction: .easeInOut)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                entity.components.remove(FlippedComponent.self)
                entity.components.remove(IsFlippingBackComponent.self)
            }
        }
    }
    
    func animateDisappear(entity: Entity) {
        var bounceTransform = entity.transform
        bounceTransform.scale *= 1.2
        bounceTransform.translation.y += 0.05
        entity.move(to: bounceTransform, relativeTo: entity.parent, duration: 0.2, timingFunction: .easeInOut)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            var shrinkTransform = bounceTransform
            shrinkTransform.scale = [0, 0, 0]
            shrinkTransform.rotation *= simd_quatf(angle: .pi, axis: [0, 1, 0])

            entity.move(to: shrinkTransform, relativeTo: entity.parent, duration: 0.3, timingFunction: .easeInOut)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                entity.removeFromParent()
            }
        }
    }

    func nextMode(after mode: GameModes) -> GameModes? {
        switch mode {
        case .easy:
            appModel.currentGameMode = GameModes.medium
            return .medium
        case .medium:
            appModel.currentGameMode = GameModes.challenging
            return .challenging
        case .challenging:
            appModel.currentGameMode = nil
            return nil
        }
    }

    //
}

#Preview(immersionStyle: .mixed) {
    MemoryGameImmersive()
        .environment(AppModel())
}
