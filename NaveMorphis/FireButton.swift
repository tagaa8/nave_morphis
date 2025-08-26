import SpriteKit

class FireButton: SKNode {
    
    private let backgroundNode: SKShapeNode
    private let iconNode: SKLabelNode
    var isPressed = false
    
    init(size: CGSize) {
        // Background circle
        backgroundNode = SKShapeNode(circleOfRadius: size.width / 2)
        backgroundNode.fillColor = .red.withAlphaComponent(0.3)
        backgroundNode.strokeColor = .red.withAlphaComponent(0.6)
        backgroundNode.lineWidth = 3
        
        // Fire icon
        iconNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        iconNode.text = "🔥"
        iconNode.fontSize = 36
        iconNode.verticalAlignmentMode = .center
        iconNode.horizontalAlignmentMode = .center
        
        super.init()
        
        addChild(backgroundNode)
        addChild(iconNode)
        
        alpha = 0.8
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func touchBegan(_ location: CGPoint) {
        let localLocation = convert(location, from: parent!)
        let distance = sqrt(localLocation.x * localLocation.x + localLocation.y * localLocation.y)
        
        if distance <= backgroundNode.frame.width / 2 {
            isPressed = true
            pressedVisuals()
        }
    }
    
    func touchMoved(_ location: CGPoint) {
        let localLocation = convert(location, from: parent!)
        let distance = sqrt(localLocation.x * localLocation.x + localLocation.y * localLocation.y)
        
        if distance <= backgroundNode.frame.width / 2 {
            if !isPressed {
                isPressed = true
                pressedVisuals()
            }
        } else {
            if isPressed {
                isPressed = false
                releasedVisuals()
            }
        }
    }
    
    func touchEnded() {
        isPressed = false
        releasedVisuals()
    }
    
    private func pressedVisuals() {
        // Make button more opaque and slightly smaller
        alpha = 1.0
        setScale(0.9)
        
        backgroundNode.fillColor = .red.withAlphaComponent(0.6)
        backgroundNode.strokeColor = .red
        
        // Glow effect
        let glow = SKAction.sequence([
            SKAction.scale(to: 1.0, duration: 0.1),
            SKAction.scale(to: 0.9, duration: 0.1)
        ])
        run(glow)
    }
    
    private func releasedVisuals() {
        // Return to normal state
        alpha = 0.8
        setScale(1.0)
        
        backgroundNode.fillColor = .red.withAlphaComponent(0.3)
        backgroundNode.strokeColor = .red.withAlphaComponent(0.6)
        
        // Release animation
        let release = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        run(release)
    }
}