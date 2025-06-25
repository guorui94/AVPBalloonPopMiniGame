//
//  BalloonColors.swift
//  Bubbles
//
//  Created by Amelia on 20/6/25.
//

import SwiftUI

enum BalloonColor: CaseIterable {
    case red
    case blue
    case green
    case yellow
    case purple
    case orange

    var color: Color {
        switch self {
        case .red:
            return .red //SIMD3<Float>(168, 50, 54) / 255.0
        case .blue:
            return .blue //SIMD3<Float>(50, 101, 168) / 255.0
        case .green:
            return .green //SIMD3<Float>(78, 168, 50) / 255.0
        case .yellow:
            return .yellow //SIMD3<Float>(224, 218, 40) / 255.0
        case .purple:
            return .purple //SIMD3<Float>(157, 93, 252) / 255.0
        case .orange:
            return .orange //SIMD3<Float>(217, 141, 35) / 255.0
        }
    }

}


