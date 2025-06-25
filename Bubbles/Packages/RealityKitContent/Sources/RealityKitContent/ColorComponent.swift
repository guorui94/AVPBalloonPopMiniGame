import RealityKit

// Ensure you register this component in your app’s delegate using:
// ColorComponent.registerComponent()
public struct ColorComponent: Component, Codable {
    // This is an example of adding a variable to the component.

    public var bubbleColor: SIMD3<Float> = [0,0,0]

    public init() {
    }
}
