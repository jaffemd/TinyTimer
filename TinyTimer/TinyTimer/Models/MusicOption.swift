//
//  MusicOption.swift
//  TinyTimer
//
//  Created by Matt on 7/29/25.
//

import Foundation

enum MusicOption: String, CaseIterable {
    case stormDance = "storm-dance"
    case chillHappy = "chill-happy"
    case weMadeIt = "we-made-it"
    
    var displayName: String {
        switch self {
        case .chillHappy: return "Upbeat Jovial"
        case .stormDance: return "Storm Dance"
        case .weMadeIt: return "We Made It"
        }
    }
    
    static let defaultOption: MusicOption = .stormDance
}