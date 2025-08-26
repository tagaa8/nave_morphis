import SpriteKit

class BulletNode: SKSpriteNode {
    
    enum BulletType {
        case player
        case enemy
    }
    
    private let bulletType: BulletType
    private var lifeTime: TimeInterval = 0
    private let maxLifeTime: TimeInterval = 3.0
    
    init(type: BulletType) {
        self.bulletType = type
        
        // Create bullet texture based on type
        let texture: SKTexture
        let color: UIColor
        let size = CGSize(width: 8, height: 16)
        
        switch type {
        case .player:
            texture = SKTexture(imageNamed: "spark") // Using spark as bullet texture
            color = .cyan
        case .enemy:
            texture = SKTexture(imageNamed: "spark")
            color = .red
        }
        
        super.init(texture: texture, color: color, size: size)
        
        colorBlendFactor = 0.8
        setupPhysics()
        setupVisuals()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.linearDamping = 0
        physicsBody?.allowsRotation = false
        
        switch bulletType {
        case .player:
            physicsBody?.categoryBitMask = GameArena.PhysicsCategory.playerBullet
            physicsBody?.contactTestBitMask = GameArena.PhysicsCategory.enemy | GameArena.PhysicsCategory.wall
        case .enemy:
            physicsBody?.categoryBitMask = GameArena.PhysicsCategory.enemyBullet
            physicsBody?.contactTestBitMask = GameArena.PhysicsCategory.player | GameArena.PhysicsCategory.wall
        }
        
        physicsBody?.collisionBitMask = 0
    }
    
    private func setupVisuals() {
        // Add glow effect
        let glowEffect = SKEffectNode()
        glowEffect.shouldRasterize = true
        glowEffect.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 4])
        
        let glowSprite = SKSpriteNode(texture: texture, size: CGSize(width: size.width * 1.5, height: size.height * 1.5))
        glowSprite.color = bulletType == .player ? .cyan : .red
        glowSprite.colorBlendFactor = 1.0
        glowSprite.alpha = 0.6
        
        glowEffect.addChild(glowSprite)
        glowEffect.zPosition = -1
        addChild(glowEffect)
        
        // Add trail particles
        let trail = SKEmitterNode()
        trail.particleTexture = SKTexture(imageNamed: "spark")
        trail.particleLifetime = 0.2
        trail.particleBirthRate = 50
        trail.particlePositionRange = CGVector(dx: 2, dy: 2)
        
        trail.particleSpeed = 20
        trail.particleSpeedRange = 10
        trail.emissionAngle = CGFloat.pi
        trail.emissionAngleRange = CGFloat.pi / 6
        
        trail.particleScale = 0.1
        trail.particleScaleRange = 0.05
        trail.particleScaleSpeed = -0.2
        
        trail.particleColor = bulletType == .player ? .cyan : .red
        trail.particleAlpha = 0.5
        trail.particleAlphaSpeed = -2.5
        
        trail.position = CGPoint(x: 0, y: -size.height/2)
        trail.zPosition = -2
        addChild(trail)
    }
    
    func update() {
        lifeTime += 1.0/60.0 // Assuming 60 FPS
        
        if lifeTime > maxLifeTime {
            removeFromParent()
        }
        
        // Fade out as it gets older
        let fadePercent = lifeTime / maxLifeTime
        alpha = 1.0 - fadePercent * 0.3
    }
}