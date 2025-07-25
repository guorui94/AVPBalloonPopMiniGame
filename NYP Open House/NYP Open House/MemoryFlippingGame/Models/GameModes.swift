//
//  GameModes.swift
//  NYP Open House
//
//  Created by Amelia on 14/7/25.
//

import SwiftUI

enum GameModes: CaseIterable {
    case easy
    case medium
    case challenging

    var rows: Int {
        switch self {
        case .easy: return 2
        case .medium: return 4
        case .challenging: return 4
        }
    }

    var columns: Int {
        switch self {
        case .easy: return 4
        case .medium: return 4
        case .challenging: return 6
        }
    }

    var images: [String] {
        let baseImages: [String]
        switch self {
        case .easy:
            baseImages = ["NYPLogo", "NYPSBM", "SIT", "NYPSDM"]
        case .medium:
            baseImages = ["NYPLogo", "NYPSBM", "NYPSIT", "NYPSDM"]
        case .challenging:
            baseImages = ["NYPLogo", "NYPSBM", "NYPSIT", "NYPSDM"]
        }

        let doubled = baseImages.flatMap { Array(repeating: $0, count: 2) }
        return doubled
    }

    var modes: String {
        switch self {
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .challenging:
            return "Challenging"
        }
    }

    var score: Int {
        switch self {
        case .easy:
            return 50
        case .medium:
            return 100
        case .challenging:
            return 200
        }
    }
    
    var color: UIColor {
        switch self {
        case .easy:
            return UIColor(red: 120/255, green: 200/255, blue: 65/255, alpha: 1.0)
        case .medium:
            return UIColor(red: 255/255, green: 155/255, blue: 47/255, alpha: 1.0)
        case .challenging:
            return UIColor(red: 251/255, green: 65/255, blue: 65/255, alpha: 1.0)
        }
    }
    var shadowColor: UIColor {
        switch self {
        case .easy:
            return UIColor(red: 60/255, green: 100/255, blue: 32/255, alpha: 0.4)

        case .medium:
            return UIColor(red: 128/255, green: 78/255, blue: 24/255, alpha: 0.4)

        case .challenging:
            return UIColor(red: 128/255, green: 32/255, blue: 32/255, alpha: 0.4)
        }
    }

}
