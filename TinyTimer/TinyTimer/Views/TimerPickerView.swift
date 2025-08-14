//
//  TimerPickerView.swift
//  TinyTimer
//
//  Created by Matt on 7/29/25.
//

import SwiftUI

struct TimerPickerView: View {
    @Binding var minutes: Int
    @Binding var seconds: Int
    
    var body: some View {
        // Scroll wheels underneath
        HStack(spacing: 0) {
            // Minutes Picker
            Picker("Minutes", selection: $minutes) {
                ForEach(0...60, id: \.self) { minute in
                    Text("\(minute) min").tag(minute)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(maxWidth: .infinity)
            .clipped()
            
            // Seconds Picker
            Picker("Seconds", selection: $seconds) {
                ForEach(Array(stride(from: 0, through: 50, by: 10)), id: \.self) { second in
                    Text("\(second) sec").tag(second)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(maxWidth: .infinity)
            .clipped()
        }
        .frame(height: 180)
    }
}

#Preview {
    TimerPickerView(minutes: .constant(1), seconds: .constant(30))
}
