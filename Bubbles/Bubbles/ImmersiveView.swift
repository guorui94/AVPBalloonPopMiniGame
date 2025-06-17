//
//  ImmersiveView.swift
//  Bubbles
//
//  Created by Amelia on 17/6/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State var predicate = QueryPredicate<Entity>.has(ModelComponent.self)
    @State private var timer: Timer?
    @State var bubble = Entity()
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "BubbleScene", in: realityKitContentBundle) {
                
                guard let bubble = immersiveContentEntity.findEntity(named: "Bubble") else {
                    fatalError()
                }
                
                for _ in 1...30 {
                    let bubbleClone = bubble.clone(recursive: true)
                    // randomly assign positions
                    let x = Float.random(in: -1.5...1.5)
                    let y = Float.random(in: 1...1.5)
                    let z = Float.random(in: -1.5...1.5)
                    
                    bubbleClone.position = [x, y, z]
                    content.add(bubbleClone)
                }
                        

                // Attach to camera so it appears in front of user
                let headAnchor = AnchorEntity(.head)
                immersiveContentEntity.position = [0, -0.5, -1]
                headAnchor.addChild(immersiveContentEntity)
                
                content.add(headAnchor)
            }
        }
        .gesture(SpatialTapGesture().targetedToEntity(where: predicate).onEnded({ value in
            let entity = value.entity
            var mat = entity.components[ModelComponent.self]?.materials.first as! ShaderGraphMaterial // not the correct way to do it
            
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
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
