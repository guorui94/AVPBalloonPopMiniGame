//
//  GameCard.swift
//  Bubbles
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
    @FocusState private var isFocused: Bool
    var body: some View {
        HStack {
            Spacer()

            VStack(spacing: 8) {
                Spacer()

                Text(title)
                    .font(.title)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(.title3)
                    .foregroundColor(Color.white.opacity(0.5))
                    .padding()

                Spacer()
            }

            Spacer()
        }
        .padding()
        .frame(width: 220, height: 200)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isFocused
                        ? Color.cyan.opacity(1.0) : Color.cyan.opacity(0.6),
                    lineWidth: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 3)
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .scaleEffect(isFocused ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .onTapGesture {
            action()
        }
        .focusable()
        .focused($isFocused)
        
    }
}

#Preview(windowStyle: .automatic) {
    GameCard(title: "Game 1", subtitle: "Game description here...", action: {})
        .environment(AppModel())

}
