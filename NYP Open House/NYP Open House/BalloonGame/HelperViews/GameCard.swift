//
//  GameCard.swift
//  NYP Open House
//
//  Created by Amelia on 24/6/25.
//

import Foundation
import SwiftUI

// reusable, in case more games are needed, for now other cards serves as a filler
struct GameCard: View {
    var title: String
    var subtitle: String
    var action: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.title)
                .fontWeight(.semibold)

            Text(subtitle)
                .font(.title3)
                .foregroundColor(Color.white.opacity(0.5))
                .padding()
        }
        .padding()
        .frame(width: 230, height: 220)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.cyan.opacity(0.6), lineWidth: 6)
        )
        .overlay(  // create a "glowing" effect
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 3)
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture {
            action()
        }
        .hoverEffect { effect, isActive, proxy in
            effect.scaleEffect(!isActive ? 1.0 : 1.1)
        }
    }
}

#Preview(windowStyle: .automatic) {
    GameCard(title: "Game 1", subtitle: "Game description here...", action: {})
        .environment(AppModel())

}
