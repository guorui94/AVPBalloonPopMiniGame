//
//  InstructionStep.swift
//  NYP Open House
//
//  Created by Amelia on 29/7/25.
//

import SwiftUI

struct InstructionStep: View {
    let number: Int
    let text: String
    var body: some View {
        HStack(alignment: .top) {
            Text("\(number).")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color(red: 0x91 / 255, green: 0xC8 / 255, blue: 0xE4 / 255))

            Text(text)
                .font(.title3)
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: 600, alignment: .leading)
    }
}

#Preview {
    InstructionStep(number: 1, text: "Tap on any tile to flip it over.")
        .environment(AppModel())
    
}
