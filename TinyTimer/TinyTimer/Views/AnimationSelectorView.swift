//
//  AnimationSelectorView.swift
//  TinyTimer
//
//  Created by Matt on 7/29/25.
//

import SwiftUI

struct AnimationSelectorView: View {
    @Binding var selectedAnimation: AnimationOption
    
    var body: some View {
        VStack {
            Text("Character")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.primary)
            
            Picker("Character", selection: $selectedAnimation) {
                ForEach(AnimationOption.allCases, id: \.self) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    AnimationSelectorView(selectedAnimation: .constant(.dino))
}