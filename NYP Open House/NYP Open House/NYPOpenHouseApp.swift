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
    @State private var appModel = AppModel()
    init () {
        ScoreComponent.registerComponent()
        PairComponent.registerComponent()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        // windowStyle(.plain) means there is no background, for each view, set the background as
        // .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        // in order for the background to appear. Make sure spacer/Hstack/Vstack is added to fill the screen if needed. Use frame to set the size of the window
        
        
        // add the different immersive spaces here
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
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        ImmersiveSpace(id: Module.memoryFlippingSpace.name) {
            MemoryFlippingGameImmersive()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        
     }
}

