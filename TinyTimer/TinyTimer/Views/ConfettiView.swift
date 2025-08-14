//
//  ConfettiView.swift
//  TinyTimer
//
//  Created by Matt on 8/14/25.
//

import SwiftUI
import UIKit

struct ConfettiView: UIViewRepresentable {
    @Binding var isActive: Bool
    let onTouchStop: () -> Void
    
    func makeUIView(context: Context) -> ConfettiUIView {
        let view = ConfettiUIView()
        view.onTouchStop = onTouchStop
        return view
    }
    
    func updateUIView(_ uiView: ConfettiUIView, context: Context) {
        if isActive {
            uiView.startConfetti()
        } else {
            uiView.stopConfetti()
        }
    }
}

class ConfettiUIView: UIView {
    var onTouchStop: (() -> Void)?
    private var confettiLayer: CAEmitterLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = true // Enable touch interaction to stop music and confetti
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // Stop confetti and music on any touch
        onTouchStop?()
    }
    
    func startConfetti() {
        stopConfetti() // Stop any existing confetti
        
        let emitter = CAEmitterLayer()
        confettiLayer = emitter
        
        // Position emitter across the top of the screen
        emitter.emitterPosition = CGPoint(x: bounds.width / 2, y: -50)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: bounds.width, height: 1)
        
        // Create colorful confetti cells
        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen, .systemYellow, 
            .systemOrange, .systemPurple, .systemPink, .systemTeal
        ]
        
        emitter.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            
            // Particle lifecycle
            cell.birthRate = 8
            cell.lifetime = 14.0
            cell.lifetimeRange = 2.0
            
            // Physics - slower animation
            cell.velocity = 200
            cell.velocityRange = 50
            cell.emissionLongitude = .pi // downward
            cell.emissionRange = .pi / 6 // spread angle
            
            // Rotation for flutter effect - slower spinning
            cell.spin = 2.0
            cell.spinRange = 1.0
            
            // Size variation
            cell.scale = 0.1
            cell.scaleRange = 0.05
            cell.scaleSpeed = -0.01 // even slower shrinking
            
            // Fade out over time - slower fade
            cell.alphaSpeed = -0.03
            cell.alphaRange = 0.1
            
            // Create rectangular confetti image
            cell.contents = createConfettiImage(color: color).cgImage
            
            return cell
        }
        
        layer.addSublayer(emitter)
        
        // Confetti will continue indefinitely until manually stopped via Stop button
    }
    
    func stopConfetti() {
        confettiLayer?.removeFromSuperlayer()
        confettiLayer = nil
    }
    
    private func createConfettiImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 12, height: 8)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update emitter position if view size changes
        if let emitter = confettiLayer {
            emitter.emitterPosition = CGPoint(x: bounds.width / 2, y: -50)
            emitter.emitterSize = CGSize(width: bounds.width, height: 1)
        }
    }
}