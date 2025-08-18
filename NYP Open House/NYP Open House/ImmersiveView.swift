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
    @Environment(AppModel.self) var appModel

    var body: some View {
        RealityView { content, attachments in
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
            let worldAnchor = AnchorEntity(world: [0, spawnY, spawnZ])
            
            content.add(worldAnchor)
            if let skyEntity = try? await Entity(
                named: "SkyScene", in: realityKitContentBundle)
            {
                let skyAnchor = AnchorEntity()
                skyAnchor.addChild(skyEntity)
                content.add(skyAnchor)
            }
            
            Task {
                if let overlayTag = attachments.entity(for: "Testing") {
                    worldAnchor.addChild(overlayTag)
                }
            }
            
        } attachments: {
            Attachment(id: "Testing") {
                StartingInterface()
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
