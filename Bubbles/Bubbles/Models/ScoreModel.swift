//
//  ScoreModel.swift
//  Bubbles
//
//  Created by Amelia on 20/6/25.
//

import Foundation

@Observable
class ScoreModel {
    var poppingScore: Int = 0
    
    func resetScore() {
        poppingScore = 0
    }
}
