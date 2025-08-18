//
//  AppModel.swift
//  NYP Open House
//
//  Created by Amelia on 8/7/25.
//

import SwiftUI
import AVFoundation
import RealityKit

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    
    enum AppScreen {
        case menu
        case balloonIntro
        case endGame
        case memoryGame
    }

    var immersiveSpaceState = ImmersiveSpaceState.closed

    var currentScreen: AppScreen = .menu

    var balloonPoppingsounds = [AudioFileResource]()

    init() {
        Task { @MainActor in
            do {
                for number in 1...3 {
                    let resource = try await AudioFileResource(named: "balloonpopping\(number).mp3")
                    balloonPoppingsounds.append(resource)
                }
                await pose.runArSession()
            } catch {
                fatalError("Error loading sound resources.")
            }
        }
    }
    
    private var balloonEndGame = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "signalEndGame", withExtension: "mp3")!)
    
    private var applauses = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "highScoreApplause", withExtension: "mp3")!)
    
    var score = ScoreModel()

    var pose = VisionProPose()
    
    var currentGameMode: GameModes? = .easy
    
    
    // set game states
    var isBalloonGame = false
    var isMemoryGame = false
    var gameEnds = false
    
    // functions
    func resetBalloonGame() {
        score.resetBalloonScore()
        score.balloonsRemoved = 0
    }
    
    func resetMemoryGame() {
        score.resetMemoryGameScore()
        score.flipScore = 0
    }
    
    func trackBalloonsRemoved() {
        score.balloonsRemoved += 1
        if score.balloonsRemoved >= 25 {
            gameEnds = true
        }
    }
    
    func signalEndGame () {
        balloonEndGame.play()
    }
    
    func highScoreApplause () {
        applauses.play()
    }
    
}
