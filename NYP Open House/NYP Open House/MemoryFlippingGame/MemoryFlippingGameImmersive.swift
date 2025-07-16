//
//  ImmersiveView.swift
//  NYP Open House
//
//  Created by Amelia on 8/7/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct MemoryFlippingGameImmersive: View {
    @State private var gameLogic = GameLogic()
    @State var predicate = QueryPredicate<Entity>.has(ModelComponent.self)

    var body: some View {
        RealityView { content in
            let worldAnchor = AnchorEntity(world: [0, 1.5, -0.8])

            if let immersiveContentEntity = try? await Entity(named: "ImageAnchorScene", in: realityKitContentBundle),
               let baseTile = immersiveContentEntity.findEntity(named: "Tile")
            {
                await createGameTiles(gameMode: gameLogic.currentGameMode, baseTile: baseTile, worldAnchor: worldAnchor)
                try? await Task.sleep(nanoseconds: 400_000_000)
                content.add(worldAnchor)
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToEntity(where: predicate)
                .onEnded { value in
                    let entity = value.entity
                    gameLogic.flipCount += 1
//                    gameLogic.flipped = entity.components[PairComponent.self]!.imageString
//                    print(entity.components[PairComponent.self]!.imageString)
                    animateFlip(entity: entity)
                }
        )
    }
    
    func createGameTiles(gameMode: GameModes, baseTile: Entity, worldAnchor: AnchorEntity) async {
        var images = gameMode.images
        images.shuffle()
        print(images)
        let columns = gameMode.cards
        let rows = gameMode.cards
        let spacing: Float = 0.17

        let centerTile = baseTile.clone(recursive: true)
        centerTile.position = [0, 0, 0]
        centerTile.transform.rotation = simd_quatf(angle: -.pi/2, axis: [0, 1, 0])
        centerTile.components.remove(InputTargetComponent.self)
        worldAnchor.addChild(centerTile)

        var tileIndex = 0

        outer: for row in 0..<rows {
            for col in 0..<columns {
                if row == rows / 2 && col == columns / 2 {
                    continue
                }
                if tileIndex >= images.count {
                    break outer
                }

                let imageName = images[tileIndex]
                tileIndex += 1

                let tileClone = baseTile.clone(recursive: true)
                
                guard
                    var pairComponent = tileClone.components[
                        PairComponent.self]
                else {
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
//                    
//                    pairImage.imageString = imageName
//                    tileClone.components.set(pairImage)
                } catch {
                    print("Error setting texture: \(error)")
                }

                let x = Float(col - columns / 2) * spacing
                let y = Float(rows / 2 - row) * spacing
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


}

#Preview(immersionStyle: .mixed) {
    MemoryFlippingGameImmersive()
        .environment(AppModel())
}
