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
    private var fireworkTimer: Timer?
    private var activeFireworkLayers: [CAEmitterLayer] = []
    
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
        
        // Start firework bursts
        startFireworks()
        
        // Confetti will continue indefinitely until manually stopped via Stop button
    }
    
    func stopConfetti() {
        confettiLayer?.removeFromSuperlayer()
        confettiLayer = nil
        stopFireworks()
    }
    
    private func createConfettiImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 12, height: 8)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    private func startFireworks() {
        stopFireworks() // Stop any existing fireworks
        
        // Schedule random firework bursts every 1-3 seconds
        scheduleNextFirework()
    }
    
    private func scheduleNextFirework() {
        // Random interval between 0.5-1.5 seconds for more frequent fireworks
        let randomInterval = Double.random(in: 1.0...3.0)
        
        fireworkTimer = Timer.scheduledTimer(withTimeInterval: randomInterval, repeats: false) { [weak self] _ in
            self?.createFireworkBurst()
            self?.scheduleNextFirework() // Schedule the next one
        }
    }
    
    private func createFireworkBurst() {
        // Random position across the entire screen
        let randomX = CGFloat.random(in: 0...bounds.width)
        let randomY = CGFloat.random(in: 0...bounds.height)
        let burstPosition = CGPoint(x: randomX, y: randomY)
        
        let fireworkLayer = CAEmitterLayer()
        fireworkLayer.emitterPosition = burstPosition
        fireworkLayer.emitterShape = .point
        fireworkLayer.emitterSize = CGSize(width: 1, height: 1)
        
        // Create colorful star-shaped particles
        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen, .systemYellow, 
            .systemOrange, .systemPurple, .systemPink, .systemTeal
        ]
        
        fireworkLayer.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            
            // Single burst lifecycle - smaller radius with same velocity
            cell.birthRate = 80 // More particles for denser burst
            cell.lifetime = 2.3 // Shorter lifetime for 2/3 radius (2.3s instead of 3.5s)
            cell.lifetimeRange = 0.5
            
            // Balanced explosion physics - good size, nice movement speed
            cell.velocity = 100 // Medium velocity for balanced size and movement
            cell.velocityRange = 50 // Good range for natural variation
            cell.emissionLongitude = 0 // All directions
            cell.emissionRange = .pi * 2 // Full circle
            
            // Balanced spinning for nice visual effect
            cell.spin = 2.5
            cell.spinRange = 1.2
            
            // Medium-sized particles with balanced shrinking
            cell.scale = 0.22 // Good starting size
            cell.scaleRange = 0.1
            cell.scaleSpeed = -0.08 // Moderate shrinking speed
            
            // Balanced fade for good visibility duration
            cell.alphaSpeed = -0.25 // Moderate fade to match balanced lifetime
            cell.alphaRange = 0.08
            
            // Create star-shaped firework particle
            cell.contents = createStarImage(color: color).cgImage
            
            return cell
        }
        
        layer.addSublayer(fireworkLayer)
        activeFireworkLayers.append(fireworkLayer)
        
        // Create single burst by stopping emission quickly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Stop emitting new particles after 0.1 seconds for single burst effect
            fireworkLayer.birthRate = 0
        }
        
        // Remove the firework layer after particles completely fade (shorter timing for smaller radius)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            fireworkLayer.removeFromSuperlayer()
            self?.activeFireworkLayers.removeAll { $0 === fireworkLayer }
        }
    }
    
    private func createStarImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 10, height: 10)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            color.setFill()
            
            // Draw a simple 5-pointed star
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let outerRadius: CGFloat = 4.5
            let innerRadius: CGFloat = 2.0
            
            let path = UIBezierPath()
            for i in 0..<5 {
                let angle = (Double(i) * 2.0 * Double.pi / 5.0) - Double.pi / 2.0
                let outerPoint = CGPoint(
                    x: center.x + outerRadius * cos(angle),
                    y: center.y + outerRadius * sin(angle)
                )
                let innerAngle = angle + Double.pi / 5.0
                let innerPoint = CGPoint(
                    x: center.x + innerRadius * cos(innerAngle),
                    y: center.y + innerRadius * sin(innerAngle)
                )
                
                if i == 0 {
                    path.move(to: outerPoint)
                } else {
                    path.addLine(to: outerPoint)
                }
                path.addLine(to: innerPoint)
            }
            path.close()
            path.fill()
        }
    }
    
    private func stopFireworks() {
        fireworkTimer?.invalidate()
        fireworkTimer = nil
        
        // Remove all active firework layers
        activeFireworkLayers.forEach { $0.removeFromSuperlayer() }
        activeFireworkLayers.removeAll()
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