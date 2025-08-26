import UIKit
import CoreHaptics

class HapticManager {
    static let shared = HapticManager()
    
    private var engine: CHHapticEngine?
    private var supportsHaptics: Bool = false
    
    private init() {
        checkHapticSupport()
        prepareHaptics()
    }
    
    private func checkHapticSupport() {
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }
    
    private func prepareHaptics() {
        guard supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            engine?.stoppedHandler = { reason in
                print("Haptic engine stopped: \(reason)")
            }
            
            engine?.resetHandler = { [weak self] in
                print("Haptic engine reset")
                do {
                    try self?.engine?.start()
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }
    
    func playImpact(intensity: CHHapticEvent.ParameterID = .hapticIntensity, sharpness: Float = 0.5) {
        guard supportsHaptics, let engine = engine else {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            return
        }
        
        let intensityValue = CHHapticEventParameter(parameterID: .hapticIntensity, value: sharpness)
        let sharpnessValue = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityValue, sharpnessValue], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error)")
        }
    }
    
    func playExplosion() {
        guard supportsHaptics, let engine = engine else {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }
        
        var events: [CHHapticEvent] = []
        
        for i in 0..<5 {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(5 - i) / 5.0)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: Double(i) * 0.05)
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play explosion haptic: \(error)")
        }
    }
    
    func playLaser() {
        guard supportsHaptics else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            return
        }
        
        playImpact(intensity: .hapticIntensity, sharpness: 0.3)
    }
    
    func playPowerUp() {
        guard supportsHaptics, let engine = engine else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return
        }
        
        var events: [CHHapticEvent] = []
        
        for i in 0..<3 {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: Double(i) * 0.1)
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play power-up haptic: \(error)")
        }
    }
    
    func playDamage() {
        guard supportsHaptics else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        playImpact(intensity: .hapticIntensity, sharpness: 0.9)
    }
    
    func playSelection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}