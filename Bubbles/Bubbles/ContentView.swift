//
//  ContentView.swift
//  Bubbles
//
//  Created by Amelia on 17/6/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @State private var selectedInterface: AnyView?
    var body: some View {
        if let interface = selectedInterface {
            interface
        } else {
            VStack(spacing: 20) {
                Spacer()

                Text("Welcome!")
                    .font(.system(size: 80))
                    .fontWeight(.bold)

                Text("Explore immersive games....")
                    .font(.title)
                    .padding(.bottom, 20)

                HStack(spacing: 50) {
                    Spacer()

                    GameCard(
                        title: "Balloon Popping",
                        subtitle: "Pop the balloons as fast as you can",
                        action: {
                            selectedInterface = AnyView(StartingInterface())
                        })

                    // fillers
                    GameCard(
                        title: "Game 2", subtitle: "Game descriptions here...",
                        action: {
                            // to add in the future
                        })

                    GameCard(
                        title: "Game 2", subtitle: "Game descriptions here...",
                        action: {
                            // to add in the future

                        })

                    Spacer()
                }
                
                Spacer()
                
            }
            .padding()
            .glassBackgroundEffect(
                in: RoundedRectangle(
                    cornerRadius: 32,
                    style: .continuous
                )
            )
        }
    }

}

#Preview() {
    ContentView()
        .environment(AppModel())
}
