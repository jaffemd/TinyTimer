//
//  ContentView.swift
//  TinyTimer
//
//  Created by Matt on 7/29/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var timerModel = TimerModel()
    @StateObject private var audioService = AudioService()
    @StateObject private var liveActivityManager = LiveActivityManager()
    @StateObject private var notificationService = NotificationService()
    @State private var selectedAnimation: AnimationOption = .dino
    @State private var selectedMusic: MusicOption = .stormDance
    @State private var minutes: Int = 1
    @State private var seconds: Int = 0
    
    // Validation: Ensure minimum 10 seconds total
    private var isValidTime: Bool {
        return (minutes * 60 + seconds) >= 10
    }
    
    // Check if time is zero (for disabling start button)
    private var isZeroTime: Bool {
        return (minutes * 60 + seconds) == 0
    }
    
    private var totalTime: Int {
        return (minutes * 60) + seconds
    }
    
    var body: some View {
        GeometryReader { geometry in
            let circleHeight = geometry.size.width - 20 // Dynamic height based on width with 10pt padding each side
            
            VStack(spacing: 0) {
                // App Title at top
                Text("Ready, Set, Go!")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                
                // STATIC BUTTON ROW - Fixed height, context-sensitive buttons
                VStack {
                    if !timerModel.isRunning && !timerModel.isPaused && !timerModel.isFinished {
                        // Initial state: Start button
                        Button(action: {
                            timerModel.start()
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start")
                            }
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(isZeroTime ? Color.gray : Color.green)
                            .cornerRadius(25)
                        }
                        .disabled(isZeroTime)
                        
                    } else if timerModel.isRunning || timerModel.isPaused {
                        // Running/Paused state: Timer controls
                        TimerControlsView(
                            timerModel: timerModel,
                            minutes: minutes,
                            seconds: seconds,
                            isValidTime: isValidTime,
                            isZeroTime: isZeroTime,
                            selectedMusic: selectedMusic
                        )
                        
                    } else if timerModel.isFinished {
                        // Finished state: Always show Reset button
                        Button("Reset") {
                            timerModel.reset(minutes: minutes, seconds: seconds, musicOption: selectedMusic)
                        }
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color.red)
                        .cornerRadius(25)
                        .shadow(radius: 3)
                    }
                }
                .frame(height: 60) // Fixed height for button row
                .padding(.horizontal)
                .padding(.bottom, 16)
                
                // STATIC CIRCLE - Always in same position
                TimerDisplayView(
                    timerModel: timerModel, 
                    totalTime: totalTime,
                    selectedAnimation: $selectedAnimation,
                    selectedMusic: selectedMusic,
                    minutes: minutes,
                    seconds: seconds
                )
                .frame(height: circleHeight) // Dynamic height based on device width
                
                // DYNAMIC CONTENT AREA - Everything below the circle
                ScrollView {
                    VStack(spacing: 16) {
                        // Digital clock display (only show when timer is running or finished)
                        if timerModel.isRunning || timerModel.isFinished {
                            Text(timerModel.displayTime)
                                .font(.system(size: 48, weight: .heavy, design: .rounded))
                                .foregroundColor(.green)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemGray5))
                                        .frame(width: 160, height: 80)
                                )
                                .padding(.top, 20) // Extra padding above clock when running
                        }
                        
                        // Timer completion UI
                        if timerModel.isFinished {
                            VStack(spacing: 8) {
                                Text("🎉 Time's Up! 🎉")
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                    .animation(.easeInOut(duration: 0.5), value: timerModel.isFinished)
                            }
                        }
                        
                        // Time Picker (only show in initial state)
                        if !timerModel.isRunning && !timerModel.isPaused && !timerModel.isFinished {
                            TimerPickerView(minutes: $minutes, seconds: $seconds)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .padding(.top, -8)
                        }
                        
                        // Music Selector (only show in initial state)
                        if !timerModel.isRunning && !timerModel.isPaused && !timerModel.isFinished {
                            VStack(spacing: 16) {
                                // Music Selector
                                MusicSelectorView(selectedMusic: $selectedMusic)
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        
                        // Minimal bottom padding for scrolling
                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: timerModel.isRunning)
        .animation(.easeInOut(duration: 0.3), value: timerModel.isFinished)
        .padding(.horizontal)
        .padding(.top, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .overlay(
            // Confetti overlay - appears in front of everything, stops music and confetti on touch
            ConfettiView(
                isActive: $timerModel.isShowingConfetti,
                onTouchStop: {
                    timerModel.stopMusicAndConfetti()
                }
            )
            .allowsHitTesting(true)
            .opacity(timerModel.isShowingConfetti ? 1 : 0)
        )
        .onAppear {
            // Set initial timer value and connect services
            timerModel.setTimer(minutes: minutes, seconds: seconds, musicOption: selectedMusic)
            timerModel.setAudioService(audioService)
            if #available(iOS 16.1, *) {
                timerModel.setServices(liveActivityManager: liveActivityManager, notificationService: notificationService)
                print("Live Activities available - iOS 16.1+")
            } else {
                print("Live Activities not available - iOS version too old")
            }
            
            // Setup notifications
            notificationService.setupNotificationCategories()
            Task {
                _ = await notificationService.requestPermission()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            timerModel.didEnterBackground()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            timerModel.willEnterForeground()
        }
        .onReceive(NotificationCenter.default.publisher(for: .timerStopFromNotification)) { _ in
            // Handle timer stop from notification
            timerModel.reset(minutes: minutes, seconds: seconds, musicOption: selectedMusic)
        }
        .onChange(of: minutes) { _, _ in
            // Always update timer when time changes (unless running)
            if !timerModel.isRunning {
                timerModel.setTimer(minutes: minutes, seconds: seconds, musicOption: selectedMusic)
            }
        }
        .onChange(of: seconds) { _, _ in
            // Always update timer when time changes (unless running)
            if !timerModel.isRunning {
                timerModel.setTimer(minutes: minutes, seconds: seconds, musicOption: selectedMusic)
            }
        }
    }
}

#Preview {
    ContentView()
}
