//
//  TimerDisplayView.swift
//  TinyTimer
//
//  Created by Matt on 7/29/25.
//

import SwiftUI

struct TimerDisplayView: View {
    @ObservedObject var timerModel: TimerModel
    let totalTime: Int
    @Binding var selectedAnimation: AnimationOption
    let selectedMusic: MusicOption
    let minutes: Int
    let seconds: Int
    
    @State private var swipeDirection: SwipeDirection = .none
    
    enum SwipeDirection {
        case none, left, right
    }
    
    var body: some View {
        // Circular progress with character animation inside - FIXED TOP POSITION
            GeometryReader { geometry in
                let circleSize = geometry.size.width - 20 // Large circle with 10pt padding each side
                let characterSize = circleSize * 0.65 // Scale character relative to circle
                
                ZStack {
                    // Circular progress ring
                    CircularProgressView(progress: timerModel.isRunning ? timerModel.smoothProgress : timerModel.progress(totalTime: totalTime))
                        .frame(width: circleSize, height: circleSize)
                    
                    // Character animation inside the ring (always show, but only animate when running or finished)
                    ZStack {
                        CharacterAnimationView(
                            animationOption: selectedAnimation,
                            isPlaying: timerModel.isRunning || timerModel.isFinished
                        )
                        .frame(width: characterSize, height: characterSize)
                        .aspectRatio(1, contentMode: .fit)
                        .clipped()
                        .id(selectedAnimation.rawValue) // Force view recreation on character change
                        .transition(.asymmetric(
                            insertion: .move(edge: swipeDirection == .right ? .trailing : .leading)
                                      .combined(with: .opacity)
                                      .combined(with: .scale(scale: 0.8)),
                            removal: .move(edge: swipeDirection == .right ? .leading : .trailing)
                                    .combined(with: .opacity)
                                    .combined(with: .scale(scale: 0.8))
                        ))
                        
                    }
                    
                    // Clickable navigation buttons positioned within circle bounds
                    if !timerModel.isRunning && !timerModel.isPaused && !timerModel.isFinished {
                        HStack {
                            // Left navigation button
                            Button(action: {
                                swipeDirection = .left
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    selectedAnimation = selectedAnimation.previous()
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.5))
                                    )
                                    .shadow(radius: 2)
                            }
                            
                            Spacer()
                            
                            // Right navigation button
                            Button(action: {
                                swipeDirection = .right
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    selectedAnimation = selectedAnimation.next()
                                }
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.5))
                                    )
                                    .shadow(radius: 2)
                            }
                        }
                        .frame(width: circleSize * 0.8) // Keep buttons within circle bounds
                    }
                }
                .frame(width: circleSize, height: circleSize)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // Center horizontally, center in available space
                .gesture(
                    // Only allow swipe when timer is not active
                    DragGesture(minimumDistance: 30)
                        .onEnded { value in
                            // Only process swipe if timer is not active
                            guard !timerModel.isRunning && !timerModel.isPaused && !timerModel.isFinished else { return }
                            
                            let horizontalAmount = value.translation.width
                            
                            if horizontalAmount > 30 {
                                // Swipe right - next character
                                swipeDirection = .right
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    selectedAnimation = selectedAnimation.next()
                                }
                            } else if horizontalAmount < -30 {
                                // Swipe left - previous character
                                swipeDirection = .left
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    selectedAnimation = selectedAnimation.previous()
                                }
                            }
                        }
                )
            }
        .onAppear {
            // Automatically start music when timer finishes
            if timerModel.isFinished && !timerModel.isPlayingCompletionMusic {
                timerModel.startCompletionMusic(musicOption: selectedMusic)
            }
        }
        .onChange(of: timerModel.isFinished) { _, isFinished in
            // Start music when timer finishes
            if isFinished && !timerModel.isPlayingCompletionMusic {
                timerModel.startCompletionMusic(musicOption: selectedMusic)
            }
        }
    }
}

#Preview {
    let timerModel = TimerModel()
    timerModel.setTimer(minutes: 1, seconds: 30, musicOption: .weMadeIt)
    
    return TimerDisplayView(
        timerModel: timerModel, 
        totalTime: 90,
        selectedAnimation: .constant(.dino),
        selectedMusic: .weMadeIt,
        minutes: 1,
        seconds: 30
    )
}
