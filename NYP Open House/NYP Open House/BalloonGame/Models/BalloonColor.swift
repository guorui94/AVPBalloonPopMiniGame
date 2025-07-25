//
//  BalloonColors.swift
//  NYP Open House
//
//  Created by Amelia on 20/6/25.
//

import SwiftUI

enum BalloonColor: CaseIterable {
    case red
    case green
    case purple
    case gold

    var color: CGColor {
        switch self {
        case .red:
            return CGColor(
                red: 168.0 / 255.0, green: 50.0 / 255.0, blue: 54.0 / 255.0,
                alpha: 1.0)
        case .green:
            return CGColor(red: 0, green: 0.39, blue: 0, alpha: 1)
        case .purple:
            return CGColor(red: 0.545, green: 0, blue: 0.545, alpha: 1)
        case .gold:
            return CGColor(red: 0.91, green: 0.73, blue: 0.22, alpha: 1.0)

        }
    }

    var brightenedColor: CGColor {
        return color.adjustedBrightness(by: 0.35)
    }

    var darkenedColor: CGColor {
        return color.adjustedBrightness(by: -0.2)
    }

    var swiftColor: Color {
        switch self {
        case .red:
            return Color(
                red: 168.0 / 255.0, green: 50.0 / 255.0, blue: 54.0 / 255.0)
        case .green:
            return Color(red: 0.0, green: 0.39, blue: 0.0)
        case .purple:
            return Color(red: 0.545, green: 0.0, blue: 0.545)
        case .gold:
            return Color(red: 0.91, green: 0.73, blue: 0.22)
        }
    }

    var poppingScore: Int {
        switch self {
        case .red:
            return 10
        case .green:
            return 20
        case .purple:
            return 30
        case .gold:
            return 60
        }
    }

    var findColor: String {
        switch self {
        case .red:
            return "red"
        case .green:
            return "green"
        case .purple:
            return "purple"
        case .gold:
            return "gold"
        }
    }

}
extension CGColor {
    func adjustedBrightness(by delta: CGFloat) -> CGColor {
        guard let components = self.components else { return self }

        // Clamp RGB values to [0, 1]
        let r = min(max(components[0] + delta, 0.0), 1.0)
        let g = min(max(components[1] + delta, 0.0), 1.0)
        let b = min(max(components[2] + delta, 0.0), 1.0)

        return CGColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
