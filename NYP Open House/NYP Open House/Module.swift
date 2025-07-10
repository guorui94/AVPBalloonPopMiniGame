//
//  Modules.swift
//  NYP Open House
//
//  Created by Amelia on 9/7/25.
//

import Foundation

enum Module: String, Identifiable, CaseIterable, Equatable {
    case bubbleSpace
    var id : Self {self}
    var name: String { rawValue.capitalized }
}
