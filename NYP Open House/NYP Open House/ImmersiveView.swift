//
//  ImmersiveView.swift
//  NYP Open House
//
//  Created by Amelia on 8/7/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    var body: some View {
        RealityView { content, attachments in
            if let skyEntity = try? await Entity(
                named: "SkyScene", in: realityKitContentBundle)
            {
                let skyAnchor = AnchorEntity()
                skyAnchor.addChild(skyEntity)
                content.add(skyAnchor)
            }
        } attachments: {
            Attachment(id: "Main") {
                ContentView()
            }
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
