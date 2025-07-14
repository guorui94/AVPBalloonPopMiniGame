import RealityKit
import RealityKitContent
import SwiftUI

struct MemoryFlippingGameImmersive: View {
    var body: some View {
        RealityView { content in
            let size = SIMD3<Float>(0.1, 0.1, 0.01)  // 10 x 10 x 2 cm
            let mesh = MeshResource.generateBox(size: size, cornerRadius: 0.02)

            var material = SimpleMaterial()
            material.color = .init(tint: .white, texture: nil)

            let cardEntity = ModelEntity(mesh: mesh, materials: [material])
            
            let worldAnchor = AnchorEntity(world: [0, 1.5, -0.8])
            worldAnchor.addChild(cardEntity)
            content.add(worldAnchor)

        }
    }
}

#Preview(immersionStyle: .mixed) {
    MemoryFlippingGameImmersive()
        .environment(AppModel())
}
