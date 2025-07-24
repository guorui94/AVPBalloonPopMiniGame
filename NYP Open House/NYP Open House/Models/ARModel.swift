//
//  ARModel.swift
//  NYP Open House
//
//  Created by Amelia on 14/7/25.
//

import ARKit
import Foundation

@Observable
class VisionProPose {
    let session = ARKitSession()
    let worldTracking = WorldTrackingProvider()
    private var isRunning = false

    func runArSession() async {
        do {
            try await session.run([worldTracking])
            isRunning = true
        } catch {
            print("Failed to run AR session: \(error)")
        }
    }
    func startIfNeeded() async {
        if !isRunning {
            await runArSession()
        } else {
            print("World tracking already running, skip restarting")
        }
    }

    func stopTracking() {
        isRunning = false
    }
}
