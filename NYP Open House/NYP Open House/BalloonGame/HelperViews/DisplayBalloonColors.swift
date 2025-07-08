//
//  DisplayBalloonColors.swift
//  NYP Open House
//
//  Created by Amelia on 3/7/25.
//

import SwiftUI

struct DisplayBalloonColors: View {
    var color: Color
    var points: Int
    var body: some View {
        HStack {
            Circle().fill(color).frame(width: 30, height: 30)
            Text("= \(points) point")
        }
        .font(.title)

    }
}

#Preview {
    DisplayBalloonColors(color: Color.red, points: 1)
}
