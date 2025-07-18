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
    @State private var predicate = QueryPredicate<Entity>.has(ModelComponent.self)
    @State private var worldAnchor: AnchorEntity?
    @State private var gestureEnabled: Bool = true
    @State private var firstFlippedEntity: Entity? = nil
    @State private var firstFlippedImage: String = ""
    @State private var flippedCount = 0
    @State private var currentGameMode = GameModes.easy
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
                                print(cardsPairCount)
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
        let columns = gameMode.cards
        let rows = gameMode.cards
        let spacing: Float = 0.17

        if gameMode.modes != "medium" {
            let centerTile = baseTile.clone(recursive: true)
            centerTile.position = [0, 0, 0]
            centerTile.transform.rotation = simd_quatf(angle: -.pi/2, axis: [0, 1, 0])
            centerTile.components.remove(InputTargetComponent.self)
            worldAnchor.addChild(centerTile)
        }

        var tileIndex = 0

        for row in 0..<rows {
            for col in 0..<columns {
                if row == rows / 2 && col == columns / 2 && gameMode.modes != "medium" {
                    continue
                }
                if tileIndex >= images.count {
                    break
                }

                let imageName = images[tileIndex]
                tileIndex += 1

                let tileClone = baseTile.clone(recursive: true)
                
                guard var pairComponent = tileClone.components[PairComponent.self] else {
                    fatalError()
                }
                pairComponent.imageString = imageName
                tileClone.components.set(pairComponent)
                
                let tileImage = tileClone.findEntity(named: "Image")
                guard let modelComponent = tileImage!.components[ModelComponent.self],
                      var mat = modelComponent.materials.first as? ShaderGraphMaterial else {
                    continue
                }

                do {
                    let texture = try await TextureResource(named: imageName)
                    let value = MaterialParameters.Value.textureResource(texture)
                    try mat.setParameter(name: "GetImage", value: value)
                    tileImage!.components[ModelComponent.self]?.materials = [mat]
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
        let newRotation = entity.transform.rotation * simd_quatf(angle: .pi, axis: [0, 1, 0])
        var transform = entity.transform
        transform.rotation = newRotation
        entity.move(to: transform, relativeTo: entity.parent, duration: 0.5, timingFunction: .easeInOut)
    }
    
    func flipBackAllCards(in worldAnchor: AnchorEntity) {
        for entity in worldAnchor.children {
            if entity.components.has(FlippedComponent.self) {
                let newRotation = entity.transform.rotation * simd_quatf(angle: .pi, axis: [0, 1, 0])
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
    //
}

#Preview(immersionStyle: .mixed) {
    MemoryFlippingGameImmersive()
        .environment(AppModel())
}
