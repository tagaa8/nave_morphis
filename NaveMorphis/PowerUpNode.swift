import SpriteKit

class PowerUpNode: SKSpriteNode {
    
    enum PowerUpType: CaseIterable {
        case health
        case rapidFire
        case shield
        case tripleShot
        
        var icon: String {
            switch self {
            case .health: return "❤️"
            case .rapidFire: return "⚡"
            case .shield: return "🛡️"
            case .tripleShot: return "💥"
            }
        }
        
        var color: UIColor {
            switch self {
            case .health: return .green
            case .rapidFire: return .yellow
            case .shield: return .cyan
            case .tripleShot: return .magenta
            }
        }
    }
    
    let powerUpType: PowerUpType
    var isCollected = false
    private var lifeTime: TimeInterval = 0
    private let maxLifeTime: TimeInterval = 10.0
    
    init(type: PowerUpType) {
        self.powerUpType = type
        
        let texture = PowerUpNode.createPowerUpTexture()
        super.init(texture: texture, color: type.color, size: CGSize(width: 30, height: 30))
        
        colorBlendFactor = 0.7
        setupPhysics()
        setupVisuals()
        setupAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: 15)
        physicsBody?.categoryBitMask = GameArena.PhysicsCategory.powerUp
        physicsBody?.contactTestBitMask = GameArena.PhysicsCategory.player
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
    }
    
    private func setupVisuals() {
        // Add glow effect
        let glowEffect = SKEffectNode()
        glowEffect.shouldRasterize = true
        glowEffect.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 8])
        
        let glowSprite = SKSpriteNode(texture: texture, size: CGSize(width: 40, height: 40))
        glowSprite.color = powerUpType.color
        glowSprite.colorBlendFactor = 1.0
        glowSprite.alpha = 0.6
        
        glowEffect.addChild(glowSprite)
        glowEffect.zPosition = -1
        addChild(glowEffect)
        
        // Add icon label
        let iconLabel = SKLabelNode(text: powerUpType.icon)
        iconLabel.fontSize = 20
        iconLabel.verticalAlignmentMode = .center
        iconLabel.horizontalAlignmentMode = .center
        iconLabel.zPosition = 2
        addChild(iconLabel)
        
        // Add sparkle particles
        let sparkles = SKEmitterNode()
        sparkles.particleTexture = PowerUpNode.createPowerUpTexture()
        sparkles.particleLifetime = 1.0
        sparkles.particleBirthRate = 20
        
        sparkles.particlePositionRange = CGVector(dx: 25, dy: 25)
        sparkles.emissionAngleRange = CGFloat.pi * 2
        
        sparkles.particleSpeed = 30
        sparkles.particleSpeedRange = 20
        
        sparkles.particleScale = 0.1
        sparkles.particleScaleRange = 0.05
        sparkles.particleScaleSpeed = -0.1
        
        sparkles.particleColor = powerUpType.color
        sparkles.particleAlpha = 0.6
        sparkles.particleAlphaSpeed = -0.6
        
        sparkles.zPosition = 1
        addChild(sparkles)
    }
    
    private func setupAnimations() {
        // Floating animation
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 10, duration: 1.5),
            SKAction.moveBy(x: 0, y: -10, duration: 1.5)
        ])
        run(SKAction.repeatForever(float))
        
        // Rotation animation
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 3.0)
        run(SKAction.repeatForever(rotate))
        
        // Pulsing scale
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.8),
            SKAction.scale(to: 0.9, duration: 0.8)
        ])
        run(SKAction.repeatForever(pulse))
        
        // Pulsing alpha
        let alphaPulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 1.0),
            SKAction.fadeAlpha(to: 1.0, duration: 1.0)
        ])
        run(SKAction.repeatForever(alphaPulse))
    }
    
    func update() {
        lifeTime += 1.0/60.0 // Assuming 60 FPS
        
        // Start blinking when near expiration
        if lifeTime > maxLifeTime * 0.8 {
            let blinkDuration = 0.2 - (lifeTime - maxLifeTime * 0.8) / (maxLifeTime * 0.2) * 0.15
            let blink = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: blinkDuration),
                SKAction.fadeAlpha(to: 1.0, duration: blinkDuration)
            ])
            
            removeAction(forKey: "alphaPulse")
            run(SKAction.repeatForever(blink), withKey: "blink")
        }
        
        // Remove if expired
        if lifeTime > maxLifeTime {
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let remove = SKAction.removeFromParent()
            run(SKAction.sequence([fadeOut, remove]))
            isCollected = true
        }
    }
    
    func collect() {
        guard !isCollected else { return }
        isCollected = true
        
        // Collection animation
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let remove = SKAction.removeFromParent()
        
        run(SKAction.sequence([
            SKAction.group([scaleUp, fadeOut]),
            remove
        ]))
        
        // Create collection effect
        let collectEffect = SKEmitterNode()
        collectEffect.particleTexture = PowerUpNode.createPowerUpTexture()
        collectEffect.particleLifetime = 0.5
        collectEffect.particleBirthRate = 100
        collectEffect.numParticlesToEmit = 20
        
        collectEffect.particlePositionRange = CGVector(dx: 10, dy: 10)
        collectEffect.emissionAngleRange = CGFloat.pi * 2
        
        collectEffect.particleSpeed = 80
        collectEffect.particleSpeedRange = 40
        
        collectEffect.particleScale = 0.3
        collectEffect.particleScaleRange = 0.2
        collectEffect.particleScaleSpeed = -0.4
        
        collectEffect.particleColor = powerUpType.color
        collectEffect.particleAlpha = 0.8
        collectEffect.particleAlphaSpeed = -1.6
        
        collectEffect.zPosition = 20
        parent?.addChild(collectEffect)
        
        collectEffect.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ]))
    }
    
    static func createPowerUpTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 8)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        return SKTexture(image: image)
    }
}