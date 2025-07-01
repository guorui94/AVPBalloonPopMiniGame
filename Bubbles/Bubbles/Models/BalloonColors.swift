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
    case deepgrey

    var color: CGColor {
        switch self {
        case .red:
            return CGColor(red: 168.0 / 255.0, green: 50.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0)
        case .blue:
            return CGColor(red: 0, green: 0, blue: 0.4, alpha: 1)
        case .green:
            return CGColor(red: 0, green: 0.39, blue: 0, alpha: 1)
        case .darkBrown:
            return CGColor(red: 0.3, green: 0.263, blue: 0.129, alpha: 1)
        case .purple:
            return CGColor(red: 0.545, green: 0, blue: 0.545, alpha: 1)
        case .deepgrey:
            return CGColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
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
        case .darkBrown:
            return 4
        case .purple:
            return 5
        case .deepgrey:
            return 6
        }
    }

}


