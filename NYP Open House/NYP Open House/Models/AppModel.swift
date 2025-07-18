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
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    var balloonPoppingsounds = [AudioFileResource]()
    // files that need longer time to load/ load multiple files should go into init
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
    
    // load audio files
    private var balloonEndGame = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "signalEndGame", withExtension: "mp3")!)
    
    private var applauses = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "highScoreApplause", withExtension: "mp3")!)
    
    // App Model is the main model that manages the state of various interfaces. basically this model binds/can be used in every interface including immersive interfaces
    // To keep it neat and easy to integrate new functions, create other models as observable and call the functions here, then you'd only need to import one model across interfaces
    var score = ScoreModel()

    var pose = VisionProPose()
    
    // set game states
    var isBalloonGame = false
    var isMemoryGame = false
    
    // functions
    func resetGame() {
        score.resetScore()
    }
    
    func trackBalloonsRemoved() {
        score.balloonsRemoved += 1
    }
    func resetBalloonsRemoved() {
        score.balloonsRemoved = 0
    }
    
    func signalEndGame () {
        balloonEndGame.play()
    }
    
    func highScoreApplause () {
        applauses.play()
    }
    

}
