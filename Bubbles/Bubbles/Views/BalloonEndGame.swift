//
//  BalloonEndGame.swift
//  Bubbles
//
//  Created by Amelia on 1/7/25.
//

import SwiftUI

struct BalloonEndGame: View {
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                
                Spacer()
            }
            Spacer()
        }
        .padding(40)
        .glassBackgroundEffect(
            in: RoundedRectangle(cornerRadius: 32, style: .continuous))
    }
}

#Preview {
    BalloonEndGame()
}
