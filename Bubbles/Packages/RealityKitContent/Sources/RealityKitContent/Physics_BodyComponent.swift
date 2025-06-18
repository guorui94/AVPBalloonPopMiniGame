import RealityKit

// Ensure you register this component in your app’s delegate using:
// Physics_BodyComponent.registerComponent()
public struct Physics_BodyComponent: Component, Codable {
    // This is an example of adding a variable to the component.
    var count: Int = 0

    public init() {
    }
}
