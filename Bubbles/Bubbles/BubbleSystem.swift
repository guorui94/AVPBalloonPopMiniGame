//
//  BubbleSystem.swift
//  Bubbles
//
//  Created by Amelia on 18/6/25.
//
import RealityKit
import RealityKitContent

class BubbleSystem: System {
    
    private let bubbleComponentQuery = EntityQuery(where: .has(BubbleComponent.self))
    public var speed: Float = 0.001

    required init(scene: Scene) {
    
    }
    
    func update(context: SceneUpdateContext) {
        context.scene.performQuery(bubbleComponentQuery).forEach { bubble in
            guard let bubbleComponent = bubble.components[BubbleComponent.self] else { return }
            bubble.position += bubbleComponent.direction * speed
        }
    }
}
