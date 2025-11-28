import SwiftUI
import RealityKitContent

@main
struct NYPOpenHouseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var appModel = AppModel()

    init() {
        ScoreComponent.registerComponent()
        PairComponent.registerComponent()
    }

    var body: some Scene {
        WindowGroup(id: "content") {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.plain)

        // Balloon game immersive space
        ImmersiveSpace(id: Module.bubbleSpace.name) {
            BalloonGameImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)

        ImmersiveSpace(id: Module.memorySpace.name) {
            MemoryGameImmersive()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)

        ImmersiveSpace(id: Module.startingSpace.name) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
