//
//  ImmersiveView.swift
//  Bubbles
//
//  Created by Amelia on 17/6/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

// track if the ballon has been popped, to avoid re-triggering the shader graph animation
struct PoppedComponent: Component {}
struct AboutToDisappearComponent: Component {}

struct ImmersiveView: View {
    // match any entity with a visible model component aka a 3d model
    @State var predicate = QueryPredicate<Entity>.has(ModelComponent.self)
    @State private var timer: Timer?
    @State var bubble = Entity()
    @State private var bubbleClones: [Entity] = []
    @Environment(AppModel.self) var appModel
    @State private var totalScore = 0
    @State private var popAudio: AudioFileResource?
    
    var body: some View {
        RealityView { content in
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

                for _ in 1...20 {
                    let randomColor = BalloonColor.allCases.randomElement()!
                    totalScore += randomColor.poppingScore
                    applyBalloonColor(to: bubble, using: randomColor)
                    let bubbleClone = bubble.clone(recursive: true)

                    let linearY = Float.random(in: 0.05...0.17)

                    let pm = PhysicsMotionComponent(linearVelocity: [
                        0, linearY, 0,
                    ])

                    bubbleClone.components[PhysicsMotionComponent.self] = pm

                    // randomly assign positions
                    let x = Float.random(in: -0.7...0.7)
                    let z = Float.random(in: -1...0)

                    bubbleClone.position = [x, 0, z]  // in meters
                    immersiveContentEntity.addChild(bubbleClone)
                    bubbleClones.append(bubbleClone)
                }
                print(totalScore)
                // use a world anchor to make sure the ballons spawn in front of the user
                let worldAnchor = AnchorEntity(world: [0, 1, -0.8])

                worldAnchor.addChild(immersiveContentEntity)
                content.add(worldAnchor)
            }
        }
        .onAppear {
            Task {
                do {
                    popAudio = try await AudioFileResource(
                        named: "balloonpopping.mp3")
                } catch {
                    print("❌ Failed to load audio: \(error)")
                }
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

                let updateScore = appModel.score
                updateScore.poppingScore += 1

                let frameRate: TimeInterval = 1.0 / 60.0  // 60 fps
                let duration: TimeInterval = 0.25
                let targetValue: Float = 1
                let totalFrames = Int(duration / frameRate)
                var currentFrame = 0
                var popValue: Float = 0

                timer?.invalidate()
                timer = Timer.scheduledTimer(
                    withTimeInterval: frameRate, repeats: true,
                    block: { timer in
                        currentFrame += 1
                        let progress = Float(currentFrame) / Float(totalFrames)

                        popValue = progress * targetValue

                        do {
                            try mat.setParameter(
                                name: "Pop", value: .float(popValue))
                            entity.components[ModelComponent.self]?.materials =
                                [mat]

                        } catch {
                            print(error.localizedDescription)
                        }

                        if currentFrame >= totalFrames {
                            timer.invalidate()
                            entity.removeFromParent()
                        }
                    })

            })
        )
        // sets the invisible boundary for ballons to disappear
        .task {
            Timer.scheduledTimer(withTimeInterval: 0.25 / 30.0, repeats: true) {
                _ in
                DispatchQueue.main.async {
                    for i in (0..<bubbleClones.count).reversed() {
                        let bubble = bubbleClones[i]
                        if bubble.position.y > 0.8 {
                            if !bubble.components.has(AboutToDisappearComponent.self) {
                                bubble.components.set(AboutToDisappearComponent())
                                
                                startBlinking(entity: bubble)
                            }
                        }
                    
                        if bubble.position.y >= 1.1 {
                            bubble.removeFromParent()
                            bubbleClones.remove(at: i)
                        }
                    }
                }
            }
        }

    }

    private func applyBalloonColor(to entity: Entity, using balloonColor: BalloonColor)
    {
        if let modelEntity = entity as? ModelEntity,
            var modelComponent = modelEntity.components[ModelComponent.self],
            var mat = modelComponent.materials.first as? ShaderGraphMaterial
        {
            do {
                try mat.setParameter(
                    name: "BalloonColor", value: .color(balloonColor.color))
                try mat.setParameter(
                    name: "DisappearingColor", value: .color(CGColor(red: 0, green: 0, blue: 0, alpha: 1)))
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
    
    private func startBlinking(entity: Entity,
                       colorName: String = "DisappearingColor",
                               blinkColor: CGColor = CGColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1),
                       times: Int = 3,
                       fade: Bool = true) {
        guard var modelComponent = entity.components[ModelComponent.self],
              var mat = modelComponent.materials.first as? ShaderGraphMaterial else {
            return
        }

        Task {
            for _ in 0..<times {
                if fade {
                    for step in 0...10 {
                        let t = Float(step) / 10
                        let blendedCG = CGColor(
                            red: CGFloat(t) ,
                               green: CGFloat(t) ,
                               blue: CGFloat(t) ,
                               alpha: 1.0
                           )
                        try? mat.setParameter(name: colorName, value: .color(blendedCG))
                        modelComponent.materials = [mat]
                        entity.components[ModelComponent.self] = modelComponent
                        try await Task.sleep(nanoseconds: 50_000_000)
                    }
                    for step in (0...10).reversed() {
                        let t = Float(step) / 10
                        let blendedCG = CGColor(
                               red: CGFloat(t) ,
                               green: CGFloat(t) ,
                               blue: CGFloat(t) ,
                               alpha: 1.0
                           )
                        try? mat.setParameter(name: colorName, value: .color(blendedCG))
                        modelComponent.materials = [mat]
                        entity.components[ModelComponent.self] = modelComponent
                        try await Task.sleep(nanoseconds: 50_000_000)
                    }
                } else {
                    try? mat.setParameter(name: colorName, value: .color(blinkColor))
                    modelComponent.materials = [mat]
                    entity.components[ModelComponent.self] = modelComponent
                    try await Task.sleep(nanoseconds: 500_000_000)

                    try? mat.setParameter(name: colorName, value: .color(CGColor(red: 0, green: 0, blue: 0, alpha: 1)))
                    modelComponent.materials = [mat]
                    entity.components[ModelComponent.self] = modelComponent
                    try await Task.sleep(nanoseconds: 500_000_000)
                }
            }
        }
    }



}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
