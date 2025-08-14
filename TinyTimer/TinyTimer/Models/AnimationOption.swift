//
//  AnimationOption.swift
//  TinyTimer
//
//  Created by Matt on 7/29/25.
//

import Foundation

enum AnimationOption: String, CaseIterable {
    case alpaca = "alpaca"
    case dino = "dino"
    case pig = "pig"
    
    var displayName: String {
        switch self {
        case .alpaca: return "Alpaca"
        case .dino: return "Dinosaur"
        case .pig: return "Pig"
        }
    }
    
    static let defaultOption: AnimationOption = .dino
    
    // Navigate to next animation (endless rotation)
    func next() -> AnimationOption {
        let allCases = AnimationOption.allCases
        guard let currentIndex = allCases.firstIndex(of: self) else { return self }
        let nextIndex = (currentIndex + 1) % allCases.count
        return allCases[nextIndex]
    }
    
    // Navigate to previous animation (endless rotation)
    func previous() -> AnimationOption {
        let allCases = AnimationOption.allCases
        guard let currentIndex = allCases.firstIndex(of: self) else { return self }
        let previousIndex = (currentIndex - 1 + allCases.count) % allCases.count
        return allCases[previousIndex]
    }
}