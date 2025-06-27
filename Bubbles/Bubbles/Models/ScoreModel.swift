//
//  ScoreModel.swift
//  Bubbles
//
//  Created by Amelia on 20/6/25.
//

import Foundation

@Observable
class ScoreModel {
    var score: Int = 0
    
    func resetScore() {
        score = 0
    }
}
