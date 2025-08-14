//
//  AudioService.swift
//  TinyTimer
//
//  Created by Matt on 7/30/25.
//

import Foundation
import AVFoundation
import UIKit

class AudioService: NSObject, ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var isPlayingTicking: Bool = false
    
    private var audioPlayer: AVAudioPlayer?
    private var tickingPlayer: AVAudioPlayer?
    
    override init() {
        super.init()
        setupAudioSession()
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupAudioSession(respectOtherAudio: Bool = false) {
        do {
            if respectOtherAudio {
                // For ticking sounds - mix with other audio and duck volume
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            } else {
                // For completion music - pause other apps' music and continue in background
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            }
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func setupNotifications() {
        // Stop music when app goes to background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        // Stop music when app comes back to foreground
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        // Handle audio interruptions (calls, etc.)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioInterrupted),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }
    
    @objc private func appDidEnterBackground() {
        // Only stop ticking sound, let completion music continue in background
        stopTicking()
        // Don't stop music - let it play in background if timer completes
    }
    
    @objc private func appWillEnterForeground() {
        stopMusic()
        stopTicking()
    }
    
    @objc private func audioInterrupted(notification: Notification) {
        stopMusic()
        stopTicking()
    }
    
    func startTicking() {
        // Don't start ticking if user has other audio playing
        guard !AVAudioSession.sharedInstance().isOtherAudioPlaying else {
            print("Other audio is playing, not starting ticking")
            return
        }
        
        // Stop any existing ticking
        stopTicking()
        
        // Set up audio session to mix with other audio
        setupAudioSession(respectOtherAudio: true)
        
        // Try to load and play the ticking sound
        guard let url = Bundle.main.url(forResource: "clock-ticking-60-second-countdown", withExtension: "mp3") else {
            print("Could not find ticking file: clock-ticking-60-second-countdown.mp3")
            return
        }
        
        do {
            tickingPlayer = try AVAudioPlayer(contentsOf: url)
            tickingPlayer?.volume = 0.3 // Lower volume for background ticking
            tickingPlayer?.numberOfLoops = -1 // Loop indefinitely until stopped
            
            let success = tickingPlayer?.play() ?? false
            if success {
                isPlayingTicking = true
            } else {
                print("Failed to start playing ticking")
            }
        } catch {
            print("Error creating ticking audio player: \(error)")
        }
    }
    
    func stopTicking() {
        tickingPlayer?.stop()
        tickingPlayer = nil
        isPlayingTicking = false
    }
    
    func playCompletionMusic(_ musicOption: MusicOption) {
        // Stop any currently playing music and ticking
        stopMusic()
        stopTicking()
        
        // Set up audio session for background playback with retry
        var sessionActivated = false
        let maxRetries = 3
        
        for attempt in 1...maxRetries {
            do {
                // Deactivate first, then reactivate with new category
                try AVAudioSession.sharedInstance().setActive(false)
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                try AVAudioSession.sharedInstance().setActive(true)
                print("✅ Audio session activated successfully for background playback (attempt \(attempt))")
                sessionActivated = true
                break
            } catch {
                print("⚠️ Audio session setup failed on attempt \(attempt): \(error)")
                if attempt < maxRetries {
                    // Brief delay before retry
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }
        }
        
        if !sessionActivated {
            print("❌ Failed to activate audio session after \(maxRetries) attempts")
            return
        }
        
        // Try to load and play the selected music
        guard let url = Bundle.main.url(forResource: musicOption.rawValue, withExtension: "mp3") else {
            print("Could not find music file: \(musicOption.rawValue).mp3")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.volume = 1.0 // Use system volume
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely until stopped
            
            let success = audioPlayer?.play() ?? false
            if success {
                isPlaying = true
            } else {
                print("Failed to start playing music")
            }
        } catch {
            print("Error creating audio player: \(error)")
            // Don't crash - just don't play music
        }
    }
    
    func stopMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        
        // Deactivate audio session to allow other apps to resume
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    func stopAllAudio() {
        stopMusic()
        stopTicking()
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // This shouldn't be called since we're looping, but handle it just in case
        isPlaying = false
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player decode error: \(error?.localizedDescription ?? "Unknown")")
        stopMusic()
    }
}