import SpriteKit

class VirtualJoystick: SKNode {
    
    private let backgroundNode: SKShapeNode
    private let knobNode: SKShapeNode
    private let maxRadius: CGFloat
    private var isTracking = false
    private var currentVector = CGVector.zero
    
    init(size: CGSize) {
        maxRadius = size.width / 2 - 20
        
        // Background circle
        backgroundNode = SKShapeNode(circleOfRadius: size.width / 2)
        backgroundNode.fillColor = .gray.withAlphaComponent(0.3)
        backgroundNode.strokeColor = .cyan.withAlphaComponent(0.5)
        backgroundNode.lineWidth = 3
        
        // Knob
        knobNode = SKShapeNode(circleOfRadius: 25)
        knobNode.fillColor = .cyan.withAlphaComponent(0.7)
        knobNode.strokeColor = .cyan
        knobNode.lineWidth = 2
        
        super.init()
        
        addChild(backgroundNode)
        addChild(knobNode)
        
        alpha = 0.8
        
        // Subtle pulsing animation
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 1.0),
            SKAction.fadeAlpha(to: 0.9, duration: 1.0)
        ])
        run(SKAction.repeatForever(pulse))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func touchBegan(_ location: CGPoint) {
        let localLocation = convert(location, from: parent!)
        isTracking = true
        updateKnob(to: localLocation)
    }
    
    func touchMoved(_ location: CGPoint) {
        guard isTracking else { return }
        let localLocation = convert(location, from: parent!)
        updateKnob(to: localLocation)
    }
    
    func touchEnded() {
        isTracking = false
        
        // Animate knob back to center
        let returnAction = SKAction.move(to: CGPoint.zero, duration: 0.2)
        returnAction.timingMode = .easeOut
        knobNode.run(returnAction)
        
        currentVector = CGVector.zero
        
        // Fade back
        alpha = 0.8
    }
    
    private func updateKnob(to location: CGPoint) {
        let distance = sqrt(location.x * location.x + location.y * location.y)
        
        if distance <= maxRadius {
            knobNode.position = location
            currentVector = CGVector(dx: location.x / maxRadius, dy: location.y / maxRadius)
        } else {
            // Constrain to circle
            let angle = atan2(location.y, location.x)
            let constrainedX = cos(angle) * maxRadius
            let constrainedY = sin(angle) * maxRadius
            
            knobNode.position = CGPoint(x: constrainedX, y: constrainedY)
            currentVector = CGVector(dx: constrainedX / maxRadius, dy: constrainedY / maxRadius)
        }
        
        // Increase visibility when active
        alpha = 1.0
        
        // Scale knob based on distance
        let scale = 0.8 + (distance / maxRadius) * 0.4
        knobNode.setScale(scale)
    }
    
    func getVector() -> CGVector {
        return currentVector
    }
}