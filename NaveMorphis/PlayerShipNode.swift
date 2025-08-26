import SpriteKit

class PlayerShipNode: SKSpriteNode {
    
    // MARK: - Properties
    private var thrustParticles: SKEmitterNode!
    private var shieldNode: SKShapeNode?
    var isInvulnerable = false
    private var invulnerabilityTimer: Timer?
    private var shieldTimer: Timer?
    
    init() {
        let texture = SKTexture(imageNamed: "player_ship")
        let shipSize = CGSize(width: 60, height: 60)  // Fixed size
        super.init(texture: texture, color: .clear, size: shipSize)
        
        setupPhysics()
        setupVisuals()
        setupThrustParticles()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.categoryBitMask = GameArena.PhysicsCategory.player
        physicsBody?.contactTestBitMask = GameArena.PhysicsCategory.enemy | GameArena.PhysicsCategory.enemyBullet | GameArena.PhysicsCategory.powerUp
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.linearDamping = 0.1
    }
    
    private func setupVisuals() {
        // Add subtle glow effect
        let glowEffect = SKEffectNode()
        glowEffect.shouldRasterize = true
        glowEffect.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 8])
        
        let glowSprite = SKSpriteNode(texture: texture)
        glowSprite.color = .cyan
        glowSprite.colorBlendFactor = 0.8
        glowSprite.alpha = 0.5
        glowSprite.setScale(1.2)
        
        glowEffect.addChild(glowSprite)
        glowEffect.zPosition = -1
        addChild(glowEffect)
        
        // Subtle pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.8),
            SKAction.scale(to: 0.95, duration: 0.8)
        ])
        run(SKAction.repeatForever(pulse))
    }
    
    private func setupThrustParticles() {
        thrustParticles = SKEmitterNode()
        
        // Create simple particle texture programmatically
        let particleTexture = createSimpleParticleTexture()
        thrustParticles.particleTexture = particleTexture
        
        thrustParticles.particleLifetime = 0.3
        thrustParticles.particleBirthRate = 0
        thrustParticles.particlePositionRange = CGVector(dx: 8, dy: 4)
        thrustParticles.emissionAngleRange = CGFloat.pi / 8
        
        // Movement
        thrustParticles.particleSpeed = 80
        thrustParticles.particleSpeedRange = 40
        thrustParticles.emissionAngle = CGFloat.pi * 1.5
        
        // Visual
        thrustParticles.particleScale = 0.2
        thrustParticles.particleScaleRange = 0.1
        thrustParticles.particleScaleSpeed = -0.3
        
        // Color - cyan thrust
        thrustParticles.particleColor = .cyan
        thrustParticles.particleAlpha = 0.8
        thrustParticles.particleAlphaSpeed = -2.0
        
        thrustParticles.position = CGPoint(x: 0, y: -size.height/2 - 5)
        thrustParticles.zPosition = -2
        addChild(thrustParticles)
    }
    
    private func createSimpleParticleTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 8)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        return SKTexture(image: image)
    }
    
    func showThrust(_ show: Bool) {
        thrustParticles.particleBirthRate = show ? 100 : 0
    }
    
    func activateShield() {
        guard shieldNode == nil else { return }
        
        // Create shield visual
        let shieldRadius = size.width * 0.8
        shieldNode = SKShapeNode(circleOfRadius: shieldRadius)
        shieldNode!.strokeColor = .cyan
        shieldNode!.lineWidth = 4
        shieldNode!.fillColor = .cyan.withAlphaComponent(0.15)
        shieldNode!.alpha = 0.8
        shieldNode!.zPosition = 1
        
        addChild(shieldNode!)
        
        // Shield animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.6),
            SKAction.scale(to: 0.9, duration: 0.6)
        ])
        shieldNode!.run(SKAction.repeatForever(pulse))
        
        // Shield duration
        shieldTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { [weak self] _ in
            self?.deactivateShield()
        }
    }
    
    private func deactivateShield() {
        shieldNode?.run(SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.3),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
        shieldNode = nil
        shieldTimer?.invalidate()
        shieldTimer = nil
    }
    
    func takeDamage() {
        // Check if shielded
        if shieldNode != nil {
            deactivateShield()
            return
        }
        
        // Invulnerability period
        isInvulnerable = true
        
        // Damage flash effect
        let flash = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.colorize(with: .clear, colorBlendFactor: 0.0, duration: 0.1)
        ])
        run(SKAction.repeat(flash, count: 5))
        
        // Blinking effect during invulnerability
        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.2),
            SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        ])
        run(SKAction.repeat(blink, count: 10))
        
        invulnerabilityTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.isInvulnerable = false
        }
    }
    
    deinit {
        invulnerabilityTimer?.invalidate()
        shieldTimer?.invalidate()
    }
}