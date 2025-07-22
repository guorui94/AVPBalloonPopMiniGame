//
//  GameModes.swift
//  NYP Open House
//
//  Created by Amelia on 14/7/25.
//

import Foundation

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
            return "easy"
        case .medium:
            return "medium"
        case .challenging:
            return "challenging"
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

}
