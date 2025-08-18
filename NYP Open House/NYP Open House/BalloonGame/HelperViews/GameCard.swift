//
//  GameCard.swift
//  NYP Open House
//
//  Created by Amelia on 24/6/25.
//

import Foundation
import SwiftUI

struct GameCard: View {
    var title: String
    var subtitle: String
    var action: () -> Void

    var body: some View {
        VStack(spacing: 10) { 
            Text(title)
                .font(.title)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.title3)
                .foregroundColor(Color.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .frame(width: 200)
                .lineLimit(2)
        }
        .frame(width: 240, height: 220)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.cyan.opacity(0.6), lineWidth: 6)
        )
        .overlay(
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
    GameCard(title: "Memory Quest", subtitle: "Match pairs to unlock NYP’s hidden gems.", action: {})
        .environment(AppModel())

}
