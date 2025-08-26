import SpriteKit

class EnemyShipNode: SKSpriteNode {
    
    // MARK: - Properties
    private var health = 50
    private let maxHealth = 50
    var isDestroyed: Bool { return health <= 0 }
    
    private var lastFireTime: TimeInterval = 0
    private var fireRate: TimeInterval = 2.0
    
    private var behaviorType: BehaviorType = .aggressive
    private var lastDirectionChange: TimeInterval = 0
    private var currentDirection: CGVector = CGVector.zero
    
    enum BehaviorType: CaseIterable {
        case aggressive  // Charges at player
        case defensive   // Keeps distance, fires
        case flanking    // Tries to circle player
        case kamikaze    // Charges directly at player
        case sniper      // Stays far, accurate shots
    }
    
    init() {
        let texture = SKTexture(imageNamed: "enemy_ship")
        let shipSize = CGSize(width: 50, height: 50)  // Fixed size
        super.init(texture: texture, color: .clear, size: shipSize)
        
        setupPhysics()
        setupVisuals()
        setupBehavior()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.categoryBitMask = GameArena.PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = GameArena.PhysicsCategory.playerBullet | GameArena.PhysicsCategory.player
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.linearDamping = 0.2
    }
    
    private func setupVisuals() {
        // Add red glow effect
        let glowEffect = SKEffectNode()
        glowEffect.shouldRasterize = true
        glowEffect.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 6])
        
        let glowSprite = SKSpriteNode(texture: texture)
        glowSprite.color = .red
        glowSprite.colorBlendFactor = 0.6
        glowSprite.alpha = 0.4
        glowSprite.setScale(1.1)
        
        glowEffect.addChild(glowSprite)
        glowEffect.zPosition = -1
        addChild(glowEffect)
        
        // Health bar
        createHealthBar()
        
        // Menacing pulse
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.02, duration: 1.0),
            SKAction.scale(to: 0.98, duration: 1.0)
        ])
        run(SKAction.repeatForever(pulse))
    }
    
    private func createHealthBar() {
        let healthBarBackground = SKShapeNode(rectOf: CGSize(width: 40, height: 4))
        healthBarBackground.fillColor = .darkGray
        healthBarBackground.strokeColor = .clear
        healthBarBackground.position = CGPoint(x: 0, y: size.height/2 + 15)
        healthBarBackground.zPosition = 2
        addChild(healthBarBackground)
        
        let healthBar = SKShapeNode(rectOf: CGSize(width: 40, height: 4))
        healthBar.fillColor = .red
        healthBar.strokeColor = .clear
        healthBar.position = CGPoint(x: 0, y: size.height/2 + 15)
        healthBar.zPosition = 3
        healthBar.name = "healthBar"
        addChild(healthBar)
    }
    
    private func updateHealthBar() {
        if let healthBar = childNode(withName: "healthBar") as? SKShapeNode {
            let healthPercent = CGFloat(health) / CGFloat(maxHealth)
            let newWidth = 40 * healthPercent
            healthBar.path = CGPath(rect: CGRect(x: -newWidth/2, y: -2, width: newWidth, height: 4), transform: nil)
            
            // Change color based on health
            if healthPercent > 0.6 {
                healthBar.fillColor = .green
            } else if healthPercent > 0.3 {
                healthBar.fillColor = .yellow
            } else {
                healthBar.fillColor = .red
            }
        }
    }
    
    private func setupBehavior() {
        behaviorType = BehaviorType.allCases.randomElement() ?? .aggressive
        fireRate = Double.random(in: 1.5...3.0)
        
        // Set initial direction
        currentDirection = CGVector(
            dx: CGFloat.random(in: -1...1),
            dy: CGFloat.random(in: -1...1)
        ).normalized()
    }
    
    func update(playerPosition: CGPoint, currentTime: TimeInterval) {
        updateBehavior(playerPosition: playerPosition, currentTime: currentTime)
        updateRotation(playerPosition: playerPosition)
    }
    
    private func updateBehavior(playerPosition: CGPoint, currentTime: TimeInterval) {
        let distanceToPlayer = position.distance(to: playerPosition)
        let directionToPlayer = (playerPosition - position).normalized()
        
        // Change direction periodically for unpredictability
        if currentTime - lastDirectionChange > 2.0 {
            lastDirectionChange = currentTime
            
            switch behaviorType {
            case .aggressive:
                currentDirection = directionToPlayer
                
            case .defensive:
                if distanceToPlayer < 200 {
                    // Move away from player
                    currentDirection = directionToPlayer * -1
                } else {
                    // Circle player
                    currentDirection = CGVector(dx: -directionToPlayer.dy, dy: directionToPlayer.dx)
                }
                
            case .flanking:
                // Try to circle player
                let angle = atan2(directionToPlayer.dy, directionToPlayer.dx) + CGFloat.pi/2
                currentDirection = CGVector(dx: cos(angle), dy: sin(angle))
                
            case .kamikaze:
                currentDirection = directionToPlayer * 1.5
                
            case .sniper:
                if distanceToPlayer < 300 {
                    currentDirection = directionToPlayer * -0.5
                } else {
                    currentDirection = CGVector.zero
                }
            }
        }
        
        // Apply movement
        let speed: CGFloat = behaviorType == .kamikaze ? 200 : 100
        physicsBody?.velocity = currentDirection * speed
    }
    
    private func updateRotation(playerPosition: CGPoint) {
        let angle = atan2(playerPosition.y - position.y, playerPosition.x - position.x) + CGFloat.pi/2
        zRotation = angle
    }
    
    func shouldFire(currentTime: TimeInterval) -> Bool {
        if currentTime - lastFireTime > fireRate {
            lastFireTime = currentTime
            return true
        }
        return false
    }
    
    func takeDamage(_ damage: Int) {
        health -= damage
        health = max(0, health)
        updateHealthBar()
        
        // Damage flash
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.colorize(with: .clear, colorBlendFactor: 0.0, duration: 0.1)
        ])
        run(flash)
        
        // Screen shake when damaged
        if health <= 0 {
            let shake = SKAction.sequence([
                SKAction.moveBy(x: 5, y: 0, duration: 0.05),
                SKAction.moveBy(x: -10, y: 0, duration: 0.05),
                SKAction.moveBy(x: 5, y: 0, duration: 0.05)
            ])
            run(shake)
        }
    }
}

// MARK: - Extensions

extension CGVector {
    func normalized() -> CGVector {
        let magnitude = sqrt(dx * dx + dy * dy)
        if magnitude > 0 {
            return CGVector(dx: dx / magnitude, dy: dy / magnitude)
        }
        return CGVector.zero
    }
    
    static func *(vector: CGVector, scalar: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGVector {
        return CGVector(dx: lhs.x - rhs.x, dy: lhs.y - rhs.y)
    }
}