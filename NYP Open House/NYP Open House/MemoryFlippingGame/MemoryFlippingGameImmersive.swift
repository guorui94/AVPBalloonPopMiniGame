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

    var body: some View {
        RealityView { content in
            let worldAnchor = AnchorEntity(world: [0, 1.5, -0.8])

            if let immersiveContentEntity = try? await Entity(named: "ImageAnchorScene", in: realityKitContentBundle),
               let baseTile = immersiveContentEntity.findEntity(named: "Anchor")
            {
                var images = gameLogic.currentGameMode.images
                images.shuffle()

                let columns = 3
                let rows = 3
                let spacing: Float = 0.17

                let centerTile = baseTile.clone(recursive: true)
                centerTile.position = [0, 0, 0]
                centerTile.transform.rotation = simd_quatf(angle: .pi, axis: [0, 1, 0])
                worldAnchor.addChild(centerTile)
                var tileIndex = 0
                for row in 0..<rows {
                    for col in 0..<columns {
                        if row == rows / 2 && col == columns / 2 {
                            continue
                        }
                        if tileIndex >= images.count {
                            break
                        }

                        let imageName = images[tileIndex]
                        tileIndex += 1

                        let tileClone = baseTile.clone(recursive: true)

                        guard let modelComponent = tileClone.components[ModelComponent.self],
                              var mat = modelComponent.materials.first as? ShaderGraphMaterial else {
                            continue
                        }

                        do {
                            let texture = try await TextureResource(named: imageName)
                            let value = MaterialParameters.Value.textureResource(texture)
                            try mat.setParameter(name: "GetImage", value: value)
                            tileClone.components[ModelComponent.self]?.materials = [mat]
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
                try? await Task.sleep(nanoseconds: 400_000_000)
                content.add(worldAnchor)
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    MemoryFlippingGameImmersive()
        .environment(AppModel())
}

