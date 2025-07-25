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

struct MemoryFlippingGameImmersive: View {
    @Environment(AppModel.self) var appModel
    @State private var predicate = QueryPredicate<Entity>.has(ModelComponent.self)
    @State private var worldAnchor = AnchorEntity(world: [0, 1.45, -0.9])
    @State private var currentGameMode = GameModes.easy
    @State private var firstFlippedEntity: Entity? = nil
    @State private var firstFlippedImage: String = ""
    @State private var pendingFlipCount = 0
    @State private var flippedCount = 0
    @State private var cardsPairCount = 0
    @State private var moveToNextLevelSound: AudioFileResource?
    @State private var flipSuccess: AudioFileResource?

    var body: some View {
        RealityView { content, attachments in
            let pose = appModel.pose
            await pose.startIfNeeded()
            
            if let immersiveContentEntity = try? await Entity(named: "ImageAnchorScene", in: realityKitContentBundle),
               let baseTile = immersiveContentEntity.findEntity(named: "Tile")
            {
                await createGameTiles(gameMode: currentGameMode, baseTile: baseTile, worldAnchor: worldAnchor)
                
                try? await Task.sleep(nanoseconds: 400_000_000)
                content.add(worldAnchor)
                
                Task {
                    if let overlayTag = attachments.entity(for: "scoreOverlay") {
                        overlayTag.position = [-0.46, +0.7,  -0.1]
                        worldAnchor.addChild(overlayTag)
                    }
                }

            }
        } attachments: {
            Attachment(id: "scoreOverlay") {
                GameOverlay()
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToEntity(where: predicate)
                .onEnded { value in
                    let entity = value.entity

                    guard !entity.components.has(FlippedComponent.self), flippedCount < 2 else { return }
                    
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
                        // wait for animation to finish before checking
                        try? await Task.sleep(nanoseconds: 300_000_000)
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
                                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                                    if let next = nextMode(after: currentGameMode) {
                                        currentGameMode = next
                                        cardsPairCount = 0
                                        worldAnchor.children.removeAll()
                                        
                                        if let immersiveContentEntity = try? await Entity(named: "ImageAnchorScene", in: realityKitContentBundle),
                                           let baseTile = immersiveContentEntity.findEntity(named: "Tile") {
                                            await createGameTiles(gameMode: next, baseTile: baseTile, worldAnchor: worldAnchor)
                                        }
                                    }
                                }
                            } else {
                                if let first = firstFlippedEntity {
                                    shakeEntity(first)
                                }
                                shakeEntity(entity)
                                try? await Task.sleep(nanoseconds: 400_000_000)
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


    }
    
    func createGameTiles(gameMode: GameModes, baseTile: Entity, worldAnchor: AnchorEntity) async {
        var images = gameMode.images
        images.shuffle()
        let rows = gameMode.rows
        let columns = gameMode.columns
        let spacing: Float = 0.13
        
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
                    try mat.setParameter(name: "GetImage", value: .textureResource(texture))
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
        textEntity.name = "GameModeLabel"
        textEntity.scale = [0.3, 0.3, 0.3]
        
        let shadowMaterial = UnlitMaterial(color: currentGameMode.shadowColor)
        let shadowEntity = ModelEntity(mesh: mesh, materials: [shadowMaterial])
        shadowEntity.scale = textEntity.scale
        
        
        shadowEntity.position = [0.005, -0.005, 0.001]
        
        if let bounds = textEntity.model?.mesh.bounds {
            let centerOffset = bounds.center.x * textEntity.scale.x
            textEntity.position.x -= centerOffset
            shadowEntity.position.x -= centerOffset
        }

        let totalHeight = Float(currentGameMode.rows - 1) * 0.13
        let labelY = (totalHeight / 2) + 0.12
        textEntity.position.y += labelY
        shadowEntity.position.y += labelY
        textEntity.position.z = 0.0
        shadowEntity.position.z = -0.001

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
            shadowEntity.position.y = (originalY - 0.005) + offset
        }

        worldAnchor.addChild(shadowEntity)
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
            if entity.components.has(FlippedComponent.self) {
                let newRotation = entity.transform.rotation * simd_quatf(angle: .pi, axis: [-1, 0, 0])
                var transform = entity.transform
                transform.rotation = newRotation
                entity.move(to: transform, relativeTo: entity.parent, duration: 0.5, timingFunction: .easeInOut)
                
                entity.components.remove(FlippedComponent.self)
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
    MemoryFlippingGameImmersive()
        .environment(AppModel())
}
