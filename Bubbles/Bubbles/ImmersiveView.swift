//
//  ImmersiveView.swift
//  Bubbles
//
//  Created by Amelia on 17/6/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

// track if the ballon has been popped, to avoid re-triggering the shader graph animation
struct PoppedComponent: Component {}

struct ImmersiveView: View {
    // match any entity with a visible model component aka a 3d model
    @State var predicate = QueryPredicate<Entity>.has(ModelComponent.self)
    @State private var timer: Timer?
    @State var bubble = Entity()
    @State private var bubbleClones: [Entity] = []
    @Environment(AppModel.self) var appModel
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "BubbleScene", in: realityKitContentBundle) {
                
                guard let bubble = immersiveContentEntity.findEntity(named: "Bubble") else {
                    fatalError()
                }
                bubble.removeFromParent()
                
                for _ in 1...15 {
                    let bubbleClone = bubble.clone(recursive: true)
                    
                    let linearY = Float.random(in: 0.05...0.13)

                    let pm = PhysicsMotionComponent(linearVelocity: [0, linearY , 0])
                    
                    bubbleClone.components[PhysicsMotionComponent.self] = pm

                    // randomly assign positions
                    let x = Float.random(in: -0.7...0.7)
                    let z = Float.random(in: -0.8...0.05)
                    
                    bubbleClone.position = [x, 0, z] // in meters
                    immersiveContentEntity.addChild(bubbleClone)
                    bubbleClones.append(bubbleClone)
                }
                        
                // use a world anchor to make sure the ballons spawn in front of the user
                let worldAnchor = AnchorEntity(world: [0, 1, -1])

                worldAnchor.addChild(immersiveContentEntity)
                content.add(worldAnchor)
            }
        }
        .gesture(SpatialTapGesture().targetedToEntity(where: predicate).onEnded({ value in
            let entity = value.entity
        
            // check if the bubble has been "popped"
            if entity.components.has(PoppedComponent.self) {
                return
            }
            
            // if not popped, set it to popped
            entity.components.set(PoppedComponent())
            let updateScore = appModel.score
            updateScore.score += 1

            
            // makes sure that material is accessed before proceeding.
            guard let modelComponent = entity.components[ModelComponent.self],
                  var mat = modelComponent.materials.first as? ShaderGraphMaterial else {
                fatalError()
            }
            
            let frameRate: TimeInterval = 1.0/60.0 // 60 fps
            let duration: TimeInterval = 0.25
            let targetValue: Float = 1
            let totalFrames = Int(duration / frameRate)
            var currentFrame = 0
            var popValue: Float = 0

            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true, block: { timer in
                currentFrame += 1
                let progress = Float(currentFrame) / Float(totalFrames)
                
                popValue = progress * targetValue
                
                do {
                    try mat.setParameter(name: "Pop", value: .float(popValue))
                    entity.components[ModelComponent.self]?.materials = [mat]
                    
                }
                catch {
                    print(error.localizedDescription)
                }
                
                
                if currentFrame >= totalFrames {
                    timer.invalidate()
                    entity.removeFromParent()
                }
            })
            
        }))
        // sets the invisible boundary for ballons to disappear 
        .task {
            Timer.scheduledTimer(withTimeInterval: 0.25 / 30.0, repeats: true) { _ in
                DispatchQueue.main.async {
                    for i in (0..<bubbleClones.count).reversed() {
                        let bubble = bubbleClones[i]
                        if bubble.position.y > 1.1 {
                            bubble.removeFromParent()
                            bubbleClones.remove(at: i)
                        }
                    }
                }
            }
        }
        
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
