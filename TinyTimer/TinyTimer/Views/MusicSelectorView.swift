//
//  MusicSelectorView.swift
//  TinyTimer
//
//  Created by Matt on 7/29/25.
//

import SwiftUI

struct MusicSelectorView: View {
    @Binding var selectedMusic: MusicOption
    
    var body: some View {
        VStack {
            Picker("Music", selection: $selectedMusic) {
                ForEach(MusicOption.allCases, id: \.self) { option in
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
    MusicSelectorView(selectedMusic: .constant(.weMadeIt))
}