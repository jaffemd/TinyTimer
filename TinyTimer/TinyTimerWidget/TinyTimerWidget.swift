//
//  TinyTimerWidget.swift
//  TinyTimerWidget
//
//  Created by Matt on 7/31/25.
//

import WidgetKit
import SwiftUI
import ActivityKit

@main
struct TinyTimerWidgets: WidgetBundle {
    var body: some Widget {
        if #available(iOS 16.1, *) {
            TimerLiveActivity()
        }
    }
}

@available(iOS 16.1, *)
struct TimerLiveActivity: Widget {
    let kind: String = "TimerLiveActivity"
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen/banner UI
            TimerLiveActivityView(context: context)
                .activityBackgroundTint(.clear)
        } dynamicIsland: { context in
            // Dynamic Island UI
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "timer")
                        .foregroundColor(.orange)
                        .font(.title2)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if !context.state.isFinished {
                        CircularProgressIndicator(
                            progress: Double(context.attributes.totalDuration - context.state.timeRemaining) / Double(context.attributes.totalDuration)
                        )
                        .frame(width: 24, height: 24)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 4) {
                        Text("TinyTimer")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        if context.state.isFinished {
                            Text("🎉 Time's Up!")
                                .font(.headline)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        } else {
                            Text(formatTime(context.state.timeRemaining))
                                .font(.title2)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .monospacedDigit()
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundColor(.orange)
                    .font(.caption)
            } compactTrailing: {
                if context.state.isFinished {
                    Text("🎉")
                        .font(.caption)
                        .foregroundColor(.white)
                } else {
                    Text(formatTime(context.state.timeRemaining))
                        .font(.caption)
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
            } minimal: {
                Image(systemName: "timer")
                    .foregroundColor(.orange)
                    .font(.caption2)
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

@available(iOS 16.1, *)
struct TimerLiveActivityView: View {
    let context: ActivityViewContext<TimerActivityAttributes>
    
    var body: some View {
        // This view defines the Live Activity appearance on lock screen
        HStack {
            Image(systemName: "timer")
                .foregroundColor(.orange)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("TinyTimer")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if context.state.isFinished {
                    Text("🎉 Time's Up!")
                        .font(.headline)
                        .foregroundColor(.primary)
                } else {
                    Text(formatTime(context.state.timeRemaining))
                        .font(.headline)
                        .foregroundColor(.primary)
                        .monospacedDigit()
                }
            }
            
            Spacer()
            
            // Progress indicator
            if !context.state.isFinished {
                CircularProgressIndicator(
                    progress: Double(context.attributes.totalDuration - context.state.timeRemaining) / Double(context.attributes.totalDuration)
                )
                .frame(width: 20, height: 20)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

@available(iOS 16.1, *)
struct CircularProgressIndicator: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
