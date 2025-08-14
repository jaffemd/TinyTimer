//
//  TimerActivityAttributes.swift
//  TinyTimerWidget
//
//  Created by Matt on 8/1/25.
//

import ActivityKit
import Foundation

struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic properties that will update
        var timeRemaining: Int
        var isFinished: Bool
    }
    
    // Static properties that don't change during the activity
    var totalDuration: Int
    var characterName: String
}