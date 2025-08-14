//
//  TimerControlsView.swift
//  TinyTimer
//
//  Created by Matt on 7/29/25.
//

import SwiftUI

struct TimerControlsView: View {
    @ObservedObject var timerModel: TimerModel
    let minutes: Int
    let seconds: Int
    let isValidTime: Bool
    let isZeroTime: Bool
    let selectedMusic: MusicOption
    
    var body: some View {
        HStack(spacing: 20) {
            if timerModel.isRunning {
                // Running state: Pause and Stop buttons
                Button(action: {
                    timerModel.pause()
                }) {
                    HStack {
                        Image(systemName: "pause.fill")
                        Text("Pause")
                    }
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .cornerRadius(25)
                }
                
                Button(action: {
                    timerModel.reset(minutes: minutes, seconds: seconds, musicOption: selectedMusic)
                }) {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Stop")
                    }
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .cornerRadius(25)
                }
                
            } else if timerModel.isPaused {
                // Paused state: Resume and Stop buttons
                Button(action: {
                    timerModel.resume()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Resume")
                    }
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .cornerRadius(25)
                }
                
                Button(action: {
                    timerModel.reset(minutes: minutes, seconds: seconds, musicOption: selectedMusic)
                }) {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Stop")
                    }
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .cornerRadius(25)
                }
            }
            // Note: Finished state handled in ContentView with "Start Over" button
        }
    }
}

#Preview {
    let timerModel = TimerModel()
    timerModel.setTimer(minutes: 1, seconds: 30, musicOption: .stormDance)
    
    return TimerControlsView(
        timerModel: timerModel,
        minutes: 1,
        seconds: 30,
        isValidTime: true,
        isZeroTime: false,
        selectedMusic: .stormDance
    )
}