//
//  CardImages.swift
//  NYP Open House
//
//  Created by Amelia on 14/7/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct CardImages: View {
    var body: some View {
        RealityView { content in
            let worldAnchor = AnchorEntity(world: [0, 1.5, -0.8])
            if let immersiveContentEntity = try? await Entity(
                named: "ImageAnchorScene", in: realityKitContentBundle),
                let anchor = immersiveContentEntity.findEntity(named: "Anchor"),
                let modelComponent = anchor.components[ModelComponent.self],
                var mat = modelComponent.materials.first as? ShaderGraphMaterial
            {
                do {
                    let texture = try await TextureResource(named: "NYPLogo")
                    
                    let value = MaterialParameters.Value.textureResource(
                        texture)
                    
                    try mat.setParameter(name: "GetImage", value: value)

                    try mat.setParameter(name: "Opacity", value: .float(0))
                    anchor.components[ModelComponent.self]?.materials = [
                        mat
                    ]
                } catch {
                    print("Unable to find parameter")
                }

                worldAnchor.addChild(anchor)
                content.add(worldAnchor)

                try? await Task.sleep(nanoseconds: 1_000_000_000)
                do {
                    try mat.setParameter(name: "Opacity", value: .float(1.0))
                    anchor.components[ModelComponent.self]?.materials = [
                        mat
                    ]
                } catch {
                    print("Unable to find parameter")
                }
            }

        }
    }
}

#Preview {
    CardImages()
}
