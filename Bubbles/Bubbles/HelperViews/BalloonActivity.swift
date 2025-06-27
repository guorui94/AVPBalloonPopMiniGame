//
//  BalloonActivity.swift
//  Bubbles
//
//  Created by Amelia on 27/6/25.
//

import GroupActivities

struct BalloonActivity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Balloon Popping Game"
        metadata.type = .generic
        return metadata
    }
}

