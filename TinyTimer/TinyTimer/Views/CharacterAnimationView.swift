//
//  CharacterAnimationView.swift
//  TinyTimer
//
//  Created by Matt on 7/29/25.
//

import SwiftUI
import Lottie

struct CharacterAnimationView: UIViewRepresentable {
    let animationOption: AnimationOption
    let isPlaying: Bool
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        let animationView = LottieAnimationView()
        
        // Configure animation view
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
        
        // Add to container and set up constraints
        containerView.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let animationView = uiView.subviews.first as? LottieAnimationView else { return }
        
        // Load the selected animation
        let animationName = animationOption.rawValue
        
        // Only load new animation if it's different from current
        if animationView.accessibilityIdentifier != animationName {
            if let animation = LottieAnimation.named(animationName) {
                animationView.animation = animation
                animationView.accessibilityIdentifier = animationName
            }
        }
        
        // Control playback based on isPlaying state
        if isPlaying && !animationView.isAnimationPlaying {
            animationView.play()
        } else if !isPlaying && animationView.isAnimationPlaying {
            animationView.pause()
        }
    }
}

#Preview {
    CharacterAnimationView(animationOption: .dino, isPlaying: true)
        .frame(width: 150, height: 150)
}