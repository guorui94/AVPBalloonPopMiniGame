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
    case darkBrown
    case purple
    case teal

    var color: CGColor {
        switch self {
        case .red:
            return CGColor(
                red: 168.0 / 255.0, green: 50.0 / 255.0, blue: 54.0 / 255.0,
                alpha: 1.0)
        case .blue:
            return CGColor(red: 0.165, green: 0.146, blue: 0.522, alpha: 1.0)
        case .green:
            return CGColor(red: 0, green: 0.39, blue: 0, alpha: 1)
        case .darkBrown:
            return CGColor(red: 0.3, green: 0.263, blue: 0.129, alpha: 1)
        case .purple:
            return CGColor(red: 0.545, green: 0, blue: 0.545, alpha: 1)
        case .teal:
            return CGColor(red: 0.004, green: 0.459, blue: 0.443, alpha: 1)
        }
    }

    var swiftColor: Color {
            switch self {
            case .red:
                return Color(red: 168.0 / 255.0, green: 50.0 / 255.0, blue: 54.0 / 255.0)
            case .blue:
                return Color(red: 0.165, green: 0.146, blue: 0.522)
            case .green:
                return Color(red: 0.0, green: 0.39, blue: 0.0)
            case .darkBrown:
                return Color(red: 0.3, green: 0.263, blue: 0.129)
            case .purple:
                return Color(red: 0.545, green: 0.0, blue: 0.545)
            case .teal:
                return Color(red: 0.004, green: 0.459, blue: 0.443)
            }
        }

    var poppingScore: Int {
        switch self {
        case .red:
            return 5
        case .blue:
            return 10
        case .green:
            return 15
        case .darkBrown:
            return 20
        case .purple:
            return 30
        case .teal:
            return 50
        }
    }
    
    var findColor: String {
        switch self {
        case .red:
            return "red"
        case .blue:
            return "blue"
        case .green:
            return "green"
        case .darkBrown:
            return "darkBrown"
        case .purple:
            return "purple"
        case .teal:
            return "teal"
        }
    }

}
