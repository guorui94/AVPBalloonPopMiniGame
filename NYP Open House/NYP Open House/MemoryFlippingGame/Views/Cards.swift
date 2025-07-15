//
//  Cards.swift
//  NYP Open House
//
//  Created by Amelia on 14/7/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct Cards: View {
    @State private var cardEntity: ModelEntity?

    var body: some View {
        Group {
            if let card = cardEntity {
                RealityView { content in
                    let worldAnchor = AnchorEntity(world: [0, 1.5, -0.8])
                    worldAnchor.addChild(card)
                    content.add(worldAnchor)
                }
            } else {
                ProgressView("Loading card...")
            }
        }
        .task {
            await createCard()
        }
    }

    @MainActor
    func createCard() async {
        let size = SIMD3<Float>(0.1, 0.1, 0.01)
        let mesh = MeshResource.generateBox(size: size, cornerRadius: 0.01)

        var material = SimpleMaterial()
        material.color = .init(tint: .white, texture: nil)

        let card = ModelEntity(mesh: mesh, materials: [material])

        try? await Task.sleep(nanoseconds: 500_000_000)

        self.cardEntity = card
    }
}

#Preview {
    Cards()
}

