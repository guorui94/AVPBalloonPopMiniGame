//
//  BalloonsSystem.swift
//  NYP Open House
//
//  Created by Amelia on 8/7/25.
//

import RealityKit
import RealityKitContent

class BalloonsSystem: System {
    private let bubbleComponentQuery = EntityQuery(where: .has(BubbleComponent.self))
    private let speed: Float = 0.001

    required init(scene: Scene) {
    
    }
    
    func update(context: SceneUpdateContext) {
        context.scene.performQuery(bubbleComponentQuery).forEach { bubble in
            guard let bubbleComponent = bubble.components[BubbleComponent.self] else { return }
            bubble.position += bubbleComponent.direction * speed
        }
    }
}
