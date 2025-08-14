//
//  NotificationService.swift
//  TinyTimer
//
//  Created by Matt on 8/1/25.
//

import Foundation
import UserNotifications

class NotificationService: ObservableObject {
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
    
    func scheduleTimerCompletionNotification(in seconds: TimeInterval) {
        // Cancel any existing notifications first
        cancelTimerNotification()
        
        let content = UNMutableNotificationContent()
        content.title = "🎉 Time's Up! 🎉"
        content.body = "Your timer has finished!"
        content.sound = .default
        content.categoryIdentifier = "TIMER_COMPLETE"
        
        // Use unique identifier with timestamp to avoid conflicts
        let identifier = "timer-complete-\(Date().timeIntervalSince1970)"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("Scheduled notification with ID: \(identifier) for \(seconds) seconds")
            }
        }
    }
    
    func cancelTimerNotification() {
        // Cancel all timer-related notifications
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let timerNotificationIds = requests
                .filter { $0.identifier.starts(with: "timer-complete") }
                .map { $0.identifier }
            
            if !timerNotificationIds.isEmpty {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: timerNotificationIds)
                print("Cancelled \(timerNotificationIds.count) timer notifications")
            }
        }
    }
    
    func setupNotificationCategories() {
        let stopAction = UNNotificationAction(
            identifier: "STOP_TIMER",
            title: "Stop & Reset",
            options: [.foreground]
        )
        
        let category = UNNotificationCategory(
            identifier: "TIMER_COMPLETE",
            actions: [stopAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}