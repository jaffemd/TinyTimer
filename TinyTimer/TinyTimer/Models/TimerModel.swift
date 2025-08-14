//
//  TimerModel.swift
//  TinyTimer
//
//  Created by Matt on 7/29/25.
//

import Foundation
import Combine
import ActivityKit

class TimerModel: ObservableObject {
    @Published var timeRemaining: Int = 0
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var isFinished: Bool = false
    @Published var isPlayingCompletionMusic: Bool = false
    @Published var isShowingConfetti: Bool = false
    @Published var smoothProgress: Double = 0.0
    
    private var timer: Timer?
    private var backgroundTime: Date?
    private var audioService: AudioService?
    private var startTime: Date?
    private var totalDuration: Int = 0
    private var liveActivityManager: LiveActivityManager?
    private var notificationService: NotificationService?
    private var selectedMusic: MusicOption = .stormDance
    
    // Set timer duration (in seconds)
    func setTimer(minutes: Int, seconds: Int, musicOption: MusicOption = .stormDance) {
        let totalSeconds = (minutes * 60) + seconds
        // Store the actual selected time (don't enforce minimum here for display)
        timeRemaining = totalSeconds
        totalDuration = totalSeconds
        selectedMusic = musicOption
        smoothProgress = 0.0
        isFinished = false
        isPaused = false
        isPlayingCompletionMusic = false
    }
    
    // Set audio service reference
    func setAudioService(_ audioService: AudioService) {
        self.audioService = audioService
    }
    
    // Set live activity and notification services
    func setServices(liveActivityManager: LiveActivityManager, notificationService: NotificationService) {
        self.liveActivityManager = liveActivityManager
        self.notificationService = notificationService
    }
    
    // Start the countdown
    func start() {
        guard timeRemaining >= 10 && !isRunning else { return }
        
        isRunning = true
        isFinished = false
        startTime = Date()
        
        // Start ticking sound
        audioService?.startTicking()
        
        // Start Live Activity for Dynamic Island
        if #available(iOS 16.1, *) {
            Task {
                await liveActivityManager?.startTimerActivity(
                    totalDuration: totalDuration,
                    characterName: "Dino" // TODO: Use actual selected character
                )
            }
        }
        
        // Schedule completion notification
        notificationService?.scheduleTimerCompletionNotification(in: TimeInterval(timeRemaining))
        
        // Use ultra-high-frequency timer for smooth progress animation
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    // Pause the countdown
    func pause() {
        guard isRunning else { return }
        isRunning = false
        isPaused = true
        timer?.invalidate()
        timer = nil
        
        // Stop ticking sound
        audioService?.stopTicking()
        
        // Cancel notification when user manually pauses
        notificationService?.cancelTimerNotification()
    }
    
    // Resume the countdown
    func resume() {
        guard isPaused && !isFinished else { return }
        isPaused = false
        isRunning = true
        startTime = Date().addingTimeInterval(-Double(totalDuration - timeRemaining))
        
        // Start ticking sound
        audioService?.startTicking()
        
        // Use ultra-high-frequency timer for smooth progress animation
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    // Stop the countdown
    func stop() {
        isRunning = false
        isPaused = false
        timer?.invalidate()
        timer = nil
        
        // Stop ticking sound
        audioService?.stopTicking()
        
        // Update Live Activity (don't end it, let it show completion)
        if #available(iOS 16.1, *) {
            Task {
                await liveActivityManager?.endTimerActivity()
            }
        }
        
        // Don't cancel notification here - let it fire for background completion
    }
    
    // Force stop everything (used when user manually stops/resets)
    func forceStop() {
        stop()
        // Cancel notification when user manually stops
        notificationService?.cancelTimerNotification()
    }
    
    // Reset the timer
    func reset(minutes: Int, seconds: Int, musicOption: MusicOption = .stormDance) {
        forceStop()
        audioService?.stopAllAudio()
        setTimer(minutes: minutes, seconds: seconds, musicOption: musicOption)
        isFinished = false
        isPlayingCompletionMusic = false
        isShowingConfetti = false
    }
    
    // Stop completion music only
    func stopCompletionMusic() {
        audioService?.stopMusic()
        isPlayingCompletionMusic = false
    }
    
    // Stop confetti animation
    func stopConfetti() {
        isShowingConfetti = false
    }
    
    // Stop both music and confetti (used for touch handling)
    func stopMusicAndConfetti() {
        stopCompletionMusic()
        stopConfetti()
    }
    
    // Handle background/foreground transitions
    func didEnterBackground() {
        backgroundTime = Date()
    }
    
    func willEnterForeground() {
        guard let backgroundTime = backgroundTime, isRunning else { return }
        
        let timeInBackground = Int(Date().timeIntervalSince(backgroundTime))
        timeRemaining = max(0, timeRemaining - timeInBackground)
        
        if timeRemaining == 0 {
            timerFinished()
        } else {
            // Timer is still running, resume ticking sound
            audioService?.startTicking()
        }
        
        self.backgroundTime = nil
    }
    
    // Private countdown tick
    private func tick() {
        guard let startTime = startTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let newTimeRemaining = max(0, totalDuration - Int(elapsed))
        
        // Update time remaining (for display)
        timeRemaining = newTimeRemaining
        
        // Update smooth progress (for circle animation)
        if totalDuration > 0 {
            smoothProgress = min(1.0, elapsed / Double(totalDuration))
        }
        
        // Update Live Activity when time changes
        if #available(iOS 16.1, *) {
            let previousTime = totalDuration - Int(elapsed - 0.016) // Previous tick time
            if newTimeRemaining != previousTime {
                Task {
                    await liveActivityManager?.updateTimerActivity(timeRemaining: newTimeRemaining)
                }
            }
        }
        
        if newTimeRemaining == 0 {
            timerFinished()
        }
    }
    
    // Handle timer completion  
    private func timerFinished() {
        stop()
        isFinished = true
        
        // Update Live Activity to show completion (keep it visible)
        if #available(iOS 16.1, *) {
            Task {
                await liveActivityManager?.updateTimerActivity(timeRemaining: 0)
            }
        }
        
        // Start completion music and confetti immediately (even in background)
        // Use background task to ensure audio can start
        DispatchQueue.main.async { [weak self] in
            if let audioService = self?.audioService, let selectedMusic = self?.selectedMusic {
                audioService.playCompletionMusic(selectedMusic)
                self?.isPlayingCompletionMusic = true
                self?.isShowingConfetti = true
            }
        }
    }
    
    // Start completion music (called from UI)
    func startCompletionMusic(musicOption: MusicOption) {
        audioService?.playCompletionMusic(musicOption)
        isPlayingCompletionMusic = true
    }
    
    // Helper to format time display
    var displayTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Progress for circular progress view (0.0 to 1.0)
    func progress(totalTime: Int) -> Double {
        guard totalTime > 0 else { return 0.0 }
        return Double(totalTime - timeRemaining) / Double(totalTime)
    }
}