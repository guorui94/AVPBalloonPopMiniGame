//
//  NYP_Open_HouseApp.swift
//  NYP Open House
//
//  Created by Amelia on 8/7/25.
//

import SwiftUI
import RealityKitContent

@main
struct NYPOpenHouseApp: App {
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var appModel = AppModel()
    init () {
        ScoreComponent.registerComponent()
        PairComponent.registerComponent()
    }
    var body: some Scene {
        WindowGroup(id: "content") {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.plain)

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

