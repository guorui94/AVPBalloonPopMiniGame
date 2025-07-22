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
    @State private var worldAnchor: AnchorEntity?
    @State private var gestureEnabled: Bool = true
    @State private var currentGameMode = GameModes.easy
    @State private var firstFlippedEntity: Entity? = nil
    @State private var firstFlippedImage: String = ""
    @State private var flippedCount = 0
    @State private var cardsPairCount = 0
    var body: some View {
        RealityView { content in
            
            worldAnchor = AnchorEntity(world: [0, 1.5, -0.8])
            if let immersiveContentEntity = try? await Entity(named: "ImageAnchorScene", in: realityKitContentBundle),
               let baseTile = immersiveContentEntity.findEntity(named: "Tile")
            {
                await createGameTiles(gameMode: GameModes.easy, baseTile: baseTile, worldAnchor: worldAnchor!)
                try? await Task.sleep(nanoseconds: 400_000_000)
                content.add(worldAnchor!)
            }
        }
        .gesture(
            gestureEnabled ?
            SpatialTapGesture()
                .targetedToEntity(where: predicate)
                .onEnded { value in
                    let entity = value.entity
                    if entity.components.has(FlippedComponent.self) {
                        return
                    }
                    let imagePair = entity.components[PairComponent.self]!.imageString
                    let pairScore = entity.components[ScoreComponent.self]!.score
                    let score = appModel.score
                    entity.components.set(FlippedComponent())
                    animateFlip(entity: entity)
                    
                    flippedCount += 1
                    
                    if flippedCount == 1 {
                        firstFlippedEntity = entity
                        firstFlippedImage = imagePair
                    } else if flippedCount == 2 {
                        gestureEnabled = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if imagePair == firstFlippedImage {
                                if let first = firstFlippedEntity {
                                    animateDisappear(entity: first)
                                }
                                animateDisappear(entity: entity)
                                cardsPairCount += 1
                                let totalPairs = currentGameMode.images.count / 2
                                score.flipScore += pairScore
                                
                                if cardsPairCount == totalPairs {
                                    print(score.flipScore)
                                    print("Level complete!")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        if let next = nextMode(after: currentGameMode) {
                                            currentGameMode = next
                                            cardsPairCount = 0

                                            worldAnchor?.children.removeAll()

                                            Task {
                                                if let immersiveContentEntity = try? await Entity(named: "ImageAnchorScene", in: realityKitContentBundle),
                                                   let baseTile = immersiveContentEntity.findEntity(named: "Tile"),
                                                   let anchor = worldAnchor {
                                                    await createGameTiles(gameMode: next, baseTile: baseTile, worldAnchor: anchor)
                                                }
                                            }
                                        } else {
                                            print(score.flipScore)
                                            print("All levels complete!")
                                        }
                                    }
                                }

                            } else {
                                if let anchor = worldAnchor {
                                    flipBackAllCards(in: anchor)
                                }
                            }
                            gestureEnabled = true
                            flippedCount = 0
                            firstFlippedEntity = nil
                            firstFlippedImage = ""
                        }
                    }
                } 
            : nil
        )
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
    }

    
    func animateFlip(entity: Entity) {
        let newRotation = entity.transform.rotation * simd_quatf(angle: .pi, axis: [-1, 0, 0])
        var transform = entity.transform
        transform.rotation = newRotation
        entity.move(to: transform, relativeTo: entity.parent, duration: 0.5, timingFunction: .easeInOut)
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
        var transform = entity.transform
        transform.scale = [0, 0, 0]
        entity.move(to: transform, relativeTo: entity.parent, duration: 0.5, timingFunction: .easeInOut)
        
        // similar to task.sleep but runs on main thread instead of async background thread
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            entity.removeFromParent()
        }
    }
    
    func nextMode(after mode: GameModes) -> GameModes? {
        switch mode {
        case .easy: return .medium
        case .medium: return .challenging
        case .challenging: return nil
        }
    }

    //
}

#Preview(immersionStyle: .mixed) {
    MemoryFlippingGameImmersive()
        .environment(AppModel())
}
