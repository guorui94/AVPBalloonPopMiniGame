//
//  ImmersiveView.swift
//  NYP Open House
//
//  Created by Amelia on 8/7/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct MemoryFlippingGameImmersive: View {
    var body: some View {
        ZStack {
            Cards()
            CardImages()
            
        }
    }
}

#Preview(immersionStyle: .mixed) {
    MemoryFlippingGameImmersive()
        .environment(AppModel())
}
