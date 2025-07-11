//
//  AppModel.swift
//  NYP Open House
//
//  Created by Amelia on 8/7/25.
//

import SwiftUI
import AVFoundation
import RealityKit

// create uniqie immersive space IDs for different spaces
enum ImmersiveSpaceID {
    case bubbleSpace
}

extension ImmersiveSpaceID {
    var stringValue: String {
        switch self {
        case .bubbleSpace:
            return "bubbleSpace"
        }
    }
}

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    // change the immersive space id before calling openImmersiveSpace()
    let immersiveSpaceId = ImmersiveSpaceID.bubbleSpace.stringValue
    
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    // files that need longer time to load/ when require to load multiple files should go into init
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
    
    // App Model is the main model that manages the state of various interfaces basically this model binds/can be used in every interface including immersive interfaces
    // To keep it neat and easy to integrate new functions, create other models as observable and call the functions here, then you'd only need to import one model across interfaces
    var score = ScoreModel()
    
    func resetGame() {
        score.resetScore()
    }
    
    func trackBalloonsRemoved() {
        score.balloonsRemoved += 1
    }
    func resetBalloonsRemoved() {
        score.balloonsRemoved = 0
    }
    
    // load audio files
    var balloonPoppingsounds = [AudioFileResource]()
    
    private var balloonEndGame = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "signalEndGame", withExtension: "mp3")!)
    
    private var applauses = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "highScoreApplause", withExtension: "mp3")!)

    func signalEndGame () {
        balloonEndGame.play()
    }
    
    func highScoreApplause () {
        applauses.play()
    }
    

}
