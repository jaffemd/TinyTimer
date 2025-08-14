//
//  TinyTimerApp.swift
//  TinyTimer
//
//  Created by Matt on 7/29/25.
//

import SwiftUI
import WidgetKit
import UserNotifications

@main
struct TinyTimerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(nil) // Respect system dark/light mode
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if notification.request.identifier == "timer-complete" {
            // Show the notification as a banner even when app is open
            completionHandler([.banner, .sound])
        }
    }
    
    // Handle notification response (when user taps it)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "timer-complete" {
            if response.actionIdentifier == "STOP_TIMER" {
                // Handle stop timer action
                NotificationCenter.default.post(name: .timerStopFromNotification, object: nil)
            }
        }
        completionHandler()
    }
}

extension Notification.Name {
    static let timerStopFromNotification = Notification.Name("timerStopFromNotification")
}

// NOTE: Live Activities are embedded within the main app for simplicity
// The TimerLiveActivity widget is automatically available when the app includes ActivityKit
