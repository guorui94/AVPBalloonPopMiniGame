//
//  Modules.swift
//  NYP Open House
//
//  Created by Amelia on 9/7/25.
//

import Foundation

enum Module: String, Identifiable, CaseIterable, Equatable {
    // name of the space
    case bubbleSpace
    case memoryFlippingSpace
    
    
    // retrieve the id
    var id : Self {self}
    
    // retrieve the id as string
    var name: String { rawValue.capitalized }
}
