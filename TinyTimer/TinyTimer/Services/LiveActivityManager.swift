//
//  LiveActivityManager.swift
//  TinyTimer
//
//  Created by Matt on 8/1/25.
//

import ActivityKit
import Foundation

@available(iOS 16.1, *)
class LiveActivityManager: ObservableObject {
    private var currentActivity: Activity<TimerActivityAttributes>?
    
    func startTimerActivity(totalDuration: Int, characterName: String) async {
        // Check if Live Activities are supported and enabled
        let authInfo = ActivityAuthorizationInfo()
        print("Live Activities enabled: \(authInfo.areActivitiesEnabled)")
        
        guard authInfo.areActivitiesEnabled else {
            print("Live Activities are not enabled by user")
            return
        }
        
        // End any existing activity
        await endTimerActivity()
        
        let attributes = TimerActivityAttributes(
            totalDuration: totalDuration,
            characterName: characterName
        )
        
        let initialState = TimerActivityAttributes.ContentState(
            timeRemaining: totalDuration,
            isFinished: false
        )
        
        do {
            print("Attempting to start Live Activity with duration: \(totalDuration)")
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
            print("✅ Successfully started Live Activity: \(activity.id)")
            print("Activity state: \(activity.activityState)")
        } catch {
            print("❌ Failed to start Live Activity: \(error)")
            print("Error details: \(error.localizedDescription)")
        }
    }
    
    func updateTimerActivity(timeRemaining: Int) async {
        guard let activity = currentActivity else { return }
        
        let updatedState = TimerActivityAttributes.ContentState(
            timeRemaining: timeRemaining,
            isFinished: timeRemaining == 0
        )
        
        let content = ActivityContent(state: updatedState, staleDate: nil)
        
        do {
            await activity.update(content)
        } catch {
            print("Failed to update Live Activity: \(error)")
        }
    }
    
    func endTimerActivity() async {
        guard let activity = currentActivity else { return }
        
        let finalState = TimerActivityAttributes.ContentState(
            timeRemaining: 0,
            isFinished: true
        )
        
        let finalContent = ActivityContent(state: finalState, staleDate: nil)
        
        do {
            // Keep Live Activity visible until user dismisses - don't auto-end
            await activity.update(finalContent)
            print("Updated Live Activity to completion state (keeping visible)")
        } catch {
            print("Failed to update Live Activity to completion: \(error)")
        }
    }
    
    func forceEndActivity() async {
        guard let activity = currentActivity else { return }
        
        do {
            await activity.end(nil, dismissalPolicy: .immediate)
            currentActivity = nil
            print("Force ended Live Activity")
        } catch {
            print("Failed to force end Live Activity: \(error)")
        }
    }
}