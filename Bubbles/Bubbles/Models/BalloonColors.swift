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

    var color: CGColor {
        switch self {
        case .red:
            return CGColor(red: 168.0 / 255.0, green: 50.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0)
        case .blue:
            return CGColor(red: 50.0 / 255.0, green: 101.0 / 255.0, blue: 168.0 / 255.0, alpha: 1.0)
        case .green:
            return CGColor(red: 78.0 / 255.0, green: 168.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0)
        case .yellow:
            return CGColor(red: 224.0 / 255.0, green: 218.0 / 255.0, blue: 40.0 / 255.0, alpha: 1.0)
        case .purple:
            return CGColor(red: 157.0 / 255.0, green: 93.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
        case .orange:
            return CGColor(red: 217.0 / 255.0, green: 141.0 / 255.0, blue: 35.0 / 255.0, alpha: 1.0)
        }
    }
    
    var poppingScore: Int {
        switch self {
        case .red:
            return 1
        case .blue:
            return 2
        case .green:
            return 3
        case .yellow:
            return 4
        case .purple:
            return 5
        case .orange:
            return 6
        }
    }

}


