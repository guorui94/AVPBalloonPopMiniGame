import RealityKit

// Ensure you register this component in your app’s delegate using:
// PairComponent.registerComponent()
public struct PairComponent: Component, Codable {
    // This is an example of adding a variable to the component.
    public var imageString: String = ""

    public init() {
    }
}
