//
//  ScoreModel.swift
//  NYP Open House
//
//  Created by Amelia on 20/6/25.
//

import Foundation

@Observable
class ScoreModel {
    var poppingScore: Int = 0 {
        didSet {
            if poppingScore > balloonHighScore {
                balloonHighScore = poppingScore
                saveBalloonHighScore()
            }
        }
    }
    
    var flipScore: Int = 0 {
        didSet {
            if flipScore > memoryGameHighScore {
                memoryGameHighScore = flipScore
                saveMemoryGameHighScore()
            }
        }
    }
    
    var balloonsRemoved: Int = 0
    
    private(set) var balloonHighScore: Int = 0
    private(set) var memoryGameHighScore: Int = 0
    
    var isHighScore: Bool = false
    
    func resetBalloonScore() {
        poppingScore = 0
        isHighScore = false
    }
    
    func resetMemoryGameScore() {
        flipScore = 0
        isHighScore = false
    }
    
    private func saveBalloonHighScore() {
        isHighScore = true
        UserDefaults.standard.set(balloonHighScore, forKey: "BalloonHighScore")
    }

    private func saveMemoryGameHighScore() {
        isHighScore = true
        UserDefaults.standard.set(memoryGameHighScore, forKey: "MemoryGameHighScore")
    }
    
}
