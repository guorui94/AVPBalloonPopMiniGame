//
//  AppModel.swift
//  Bubbles
//
//  Created by Amelia on 17/6/25.
//

import SwiftUI
import AVFoundation
import RealityKit

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    // begin game logic here
    var score = ScoreModel()
    
    func resetGame() {
        score.resetScore()
    }
    
    // load audio files here
    var balloonPoppingsounds = [AudioFileResource]()
    private var balloonEndGame = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "signalEndGame", withExtension: "mp3")!)

    func signalEndGame () {
        balloonEndGame.play()
    }
    
    // files that need longer time to load should go into init
    init() {
        Task { @MainActor in
            do {
                for number in 1...3 {
                    let resource = try await AudioFileResource(named: "balloonpopping\(number).mp3")
                    balloonPoppingsounds.append(resource)
                }
            } catch {
                fatalError("Error loading sound resources.")
            }
        }
    }
}
