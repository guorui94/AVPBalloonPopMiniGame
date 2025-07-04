//
//  BubblesApp.swift
//  Bubbles
//
//  Created by Amelia on 17/6/25.
//

import SwiftUI
import RealityKitContent

@main
struct BubblesApp: App {
    @State private var appModel = AppModel()
    init () {
        ScoreComponent.registerComponent()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        // with the windowStyle as .plain, for each view, set the glass background effect as
        //.glassBackgroundEffect(in: RoundedRectangle(
        //            cornerRadius: 32,
        //            style: .continuous
        //        )
        //    ) in order for the background to appear. Make sure spacer/Hstack/Vstack is added to fill the screen if needed. Use frame to set the size of the window
        
        
        // add the different immersive spaces here
        ImmersiveSpace(id: appModel.immersiveSpaceId) {
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
        
     }
}
