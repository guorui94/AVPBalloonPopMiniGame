//
//  ScoreModel.swift
//  Bubbles
//
//  Created by Amelia on 20/6/25.
//

import Foundation

@Observable
class ScoreModel {
    var poppingScore: Int = 0 {
        didSet {
            if poppingScore > highScore {
                highScore = poppingScore
                saveHighScore()
            }
        }
    }
    
    
    var balloonsRemoved: Int = 0
    
    private(set) var highScore: Int = 0
    
    var isHighScore: Bool = false
    
    func resetScore() {
        poppingScore = 0
        isHighScore = false
    }
    
    private func saveHighScore() {
        isHighScore = true
        UserDefaults.standard.set(highScore, forKey: "HighScore")
    }

    func loadHighScore() -> Int {
        highScore = UserDefaults.standard.integer(forKey: "HighScore")
        return highScore
    }
    
}
