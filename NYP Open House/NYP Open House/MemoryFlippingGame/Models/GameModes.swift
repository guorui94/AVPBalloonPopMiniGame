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
    
    var cards: Int {
        switch self {
        case .easy:
            return 3
        case .medium:
            return 4
        case .challenging:
            return 5
        }
    }
    
    var images: [String] {
        let baseImages: [String]
        switch self {
        case .easy:
            baseImages = ["NYPLogo", "NYPSBM", "NYPSIT","NYPSDM"]
        case .medium:
            baseImages = ["NYPLogo", "NYPSBM", "NYPSIT","NYPSDM"]
        case .challenging:
            baseImages = ["NYPLogo", "NYPSBM", "NYPSIT","NYPSDM"]
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

    
}
    
