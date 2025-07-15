//
//  BalloonGameImmersiveView.swift
//  NYP Open House
//
//  Created by Amelia on 17/6/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

// track if the balloon has been popped, to avoid re-triggering the shader graph animation
struct PoppedComponent: Component {}
struct AboutToDisappearComponent: Component {}

struct BalloonGameImmersiveView: View {
    // match any entity with a visible model component aka a 3d model
    @State var predicate = QueryPredicate<Entity>.has(ModelComponent.self)
    @State private var bubbleClones: [Entity] = []
    @Environment(AppModel.self) var appModel

    var body: some View {
        RealityView { content in
            // check the ar session first
            let pose = appModel.pose
            await pose.startIfNeeded()

            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(
                named: "BubbleScene", in: realityKitContentBundle)
            {
                guard
                    let bubble = immersiveContentEntity.findEntity(
                        named: "Bubble")
                else {
                    fatalError()
                }
                bubble.removeFromParent()

                let redCount = 7
                let greenCount = 7
                let purpleCount = 7
                let goldCount = 4

                // set a fixed number ot balloons to appear in the immersive space
                var colorList: [BalloonColor] = []
                colorList += Array(repeating: .red, count: redCount)
                colorList += Array(repeating: .green, count: greenCount)
                colorList += Array(repeating: .purple, count: purpleCount)
                colorList += Array(repeating: .gold, count: goldCount)

                colorList.shuffle()

                for balloonColor in colorList {

                    applyBalloonColor(to: bubble, using: balloonColor.color)

                    guard
                        var scoreComponent = bubble.components[
                            ScoreComponent.self]
                    else {
                        fatalError()
                    }
                    scoreComponent.score = balloonColor.poppingScore
                    bubble.components.set(scoreComponent)

                    guard
                        let modelComponent = bubble.components[
                            ModelComponent.self],
                        var mat = modelComponent.materials.first
                            as? ShaderGraphMaterial
                    else {
                        fatalError()
                    }

                    do {
                        if balloonColor.findColor == "gold" {
                            try mat.setParameter(
                                name: "Shiny", value: .float(1.0))
                            try mat.setParameter(
                                name: "Metallic", value: .float(0.8))
                        } else {
                            try mat.setParameter(
                                name: "Shiny", value: .float(0.0))
                            try mat.setParameter(
                                name: "Metallic", value: .float(0.0))
                        }

                        bubble.components[ModelComponent.self]?.materials = [
                            mat
                        ]
                    } catch {
                        print(error.localizedDescription)
                    }

                    let bubbleClone = bubble.clone(recursive: true)

                    var linearY = Float.random(in: 0.05...0.13)

                    if balloonColor.findColor == "gold" {
                        linearY = Float.random(in: 0.25...0.35)
                    }

                    let pm = PhysicsMotionComponent(linearVelocity: [
                        0, linearY, 0,
                    ])

                    bubbleClone.components[PhysicsMotionComponent.self] = pm

                    // randomly assign positions
                    let x = Float.random(in: -0.7...0.7)
                    var y = Float.random(in: -0.3...0)
                    let z = Float.random(in: -1...0)

                    if balloonColor.findColor == "gold" {
                        y = 0
                    }

                    bubbleClone.position = [x, y, z]  // in meters
                    if balloonColor.findColor == "gold" {
                        // Delayed adding to scene
                        Task {
                            try? await Task.sleep(nanoseconds: 3_000_000_000)
                            immersiveContentEntity.addChild(bubbleClone)
                            bubbleClones.append(bubbleClone)
                        }
                    } else {
                        immersiveContentEntity.addChild(bubbleClone)
                        bubbleClones.append(bubbleClone)
                    }
                }
                try? await Task.sleep(nanoseconds: 500_000_000)
                var spawnY: Float = 0.0
                if let deviceAnchor = pose.worldTracking.queryDeviceAnchor(
                    atTimestamp: CACurrentMediaTime())
                {
                    let transform = deviceAnchor.originFromAnchorTransform
                    spawnY = transform.columns.3.y - 0.25
                    print("Headset position from ARKit: \(transform.columns.3.y - 0.3)")
                }

                // use a world anchor to make sure the balloons spawn in front of the user
                let worldAnchor = AnchorEntity(world: [0, spawnY, -0.8])

                worldAnchor.addChild(immersiveContentEntity)
                content.add(worldAnchor)
            }
        }
        .gesture(
            SpatialTapGesture().targetedToEntity(where: predicate).onEnded({
                value in
                let entity = value.entity

                // check if the bubble has been "popped"
                if entity.components.has(PoppedComponent.self) {
                    return
                }

                let popAudio = appModel.balloonPoppingsounds.randomElement()

                // if not popped, set it to popped
                entity.components.set(PoppedComponent())
                if let audio = popAudio {
                    entity.playAudio(audio)
                }

                // makes sure that material is accessed before proceeding.
                guard
                    let modelComponent = entity.components[ModelComponent.self],
                    var mat = modelComponent.materials.first
                        as? ShaderGraphMaterial
                else {
                    fatalError()
                }

                guard
                    let scoreComponent = entity.components[ScoreComponent.self]
                else {
                    fatalError()
                }
                appModel.score.poppingScore += scoreComponent.score

                let frameRate: TimeInterval = 1.0 / 60.0  // 60 fps
                let duration: TimeInterval = 0.25
                let targetValue: Float = 1
                let totalFrames = Int(duration / frameRate)
                var currentFrame = 0
                var popValue: Float = 0

                Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true)
                { timer in
                    currentFrame += 1
                    let progress = Float(currentFrame) / Float(totalFrames)
                    popValue = progress * targetValue

                    do {
                        try mat.setParameter(
                            name: "Pop", value: .float(popValue))
                        entity.components[ModelComponent.self]?.materials = [
                            mat
                        ]
                    } catch {
                        print(error.localizedDescription)
                    }

                    if currentFrame >= totalFrames {
                        timer.invalidate()
                        entity.removeFromParent()
                        Task { @MainActor in
                            appModel.trackBalloonsRemoved()
                        }
                    }
                }

            })
        )
        // sets the invisible boundary for balloons to disappear
        .task {
            Timer.scheduledTimer(withTimeInterval: 0.25 / 30.0, repeats: true) {
                _ in
                DispatchQueue.main.async {
                    for i in (0..<bubbleClones.count).reversed() {
                        let bubble = bubbleClones[i]
                        if bubble.position.y > 0.8 {
                            if !bubble.components.has(
                                AboutToDisappearComponent.self)
                            {
                                bubble.components.set(
                                    AboutToDisappearComponent())

                                startBlinking(entity: bubble)
                            }
                        }

                        if bubble.position.y >= 0.9 {
                            bubble.removeFromParent()
                            bubbleClones.remove(at: i)
                            Task { @MainActor in
                                appModel.trackBalloonsRemoved()
                            }
                        }
                    }
                }
            }
        }

    }

    private func applyBalloonColor(
        to entity: Entity, using balloonColor: CGColor
    ) {
        if let modelEntity = entity as? ModelEntity,
            var modelComponent = modelEntity.components[ModelComponent.self],
            var mat = modelComponent.materials.first as? ShaderGraphMaterial
        {
            do {
                try mat.setParameter(
                    name: "BalloonColor", value: .color(balloonColor))
                try mat.setParameter(
                    name: "DisappearingColor",
                    value: .color(CGColor(red: 0, green: 0, blue: 0, alpha: 0)))
                modelComponent.materials[0] = mat
                modelEntity.components[ModelComponent.self] = modelComponent

            } catch {
                // ignore the shader error
            }
        }
        for child in entity.children {
            applyBalloonColor(to: child, using: balloonColor)
        }
    }

    private func startBlinking(
        entity: Entity,
        colorName: String = "DisappearingColor",
        blinkColor: CGColor = CGColor(
            red: 0.7, green: 0.7, blue: 0.7, alpha: 1),
        times: Int = 3,
        fade: Bool = true
    ) {
        guard var modelComponent = entity.components[ModelComponent.self],
            var mat = modelComponent.materials.first as? ShaderGraphMaterial
        else {
            return
        }

        Task {
            for _ in 0..<times {
                if fade {
                    for step in 0...10 {
                        let t = Float(step) / 10
                        let blendedCG = CGColor(
                            red: CGFloat(t),
                            green: CGFloat(t),
                            blue: CGFloat(t),
                            alpha: 1.0
                        )
                        try? mat.setParameter(
                            name: colorName, value: .color(blendedCG))
                        modelComponent.materials = [mat]
                        entity.components[ModelComponent.self] = modelComponent
                        try await Task.sleep(nanoseconds: 50_000_000)
                    }
                    for step in (0...10).reversed() {
                        let t = Float(step) / 10
                        let blendedCG = CGColor(
                            red: CGFloat(t),
                            green: CGFloat(t),
                            blue: CGFloat(t),
                            alpha: 1.0
                        )
                        try? mat.setParameter(
                            name: colorName, value: .color(blendedCG))
                        modelComponent.materials = [mat]
                        entity.components[ModelComponent.self] = modelComponent
                        try await Task.sleep(nanoseconds: 50_000_000)
                    }
                } else {
                    try? mat.setParameter(
                        name: colorName, value: .color(blinkColor))
                    modelComponent.materials = [mat]
                    entity.components[ModelComponent.self] = modelComponent
                    try await Task.sleep(nanoseconds: 500_000_000)

                    try? mat.setParameter(
                        name: colorName,
                        value: .color(
                            CGColor(red: 0, green: 0, blue: 0, alpha: 1)))
                    modelComponent.materials = [mat]
                    entity.components[ModelComponent.self] = modelComponent
                    try await Task.sleep(nanoseconds: 500_000_000)
                }
            }
        }
    }

}

#Preview(immersionStyle: .mixed) {
    BalloonGameImmersiveView()
        .environment(AppModel())
}
