import RealityKit

// Ensure you register this component in your app’s delegate using:
// ScoreComponent.registerComponent()
public struct ScoreComponent: Component, Codable {
    // This is an example of adding a variable to the component.
    public var score: Int = 0
    
    public init() {
    }
}
