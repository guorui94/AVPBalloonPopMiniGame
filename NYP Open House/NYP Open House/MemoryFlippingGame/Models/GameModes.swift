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
            return 10
        case .medium:
            return 16
        case .challenging:
            return 20
        }
    }
    
    
    
    
    
}
    
