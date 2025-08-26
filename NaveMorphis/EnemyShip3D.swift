import SpriteKit
import GameplayKit

class EnemyShip3D: SKSpriteNode {
    
    // MARK: - AI Properties
    private var aiType: AIType
    private var targetPosition = CGPoint.zero
    private var velocity = CGVector.zero
    private var maxSpeed: CGFloat
    private var aggressionLevel: CGFloat
    private var lastDirectionChange: TimeInterval = 0
    private var changeDirectionInterval: TimeInterval
    
    // MARK: - Combat Properties
    private var health: Int
    private var lastFireTime: TimeInterval = 0
    private var fireInterval: TimeInterval
    private var weaponRange: CGFloat
    
    // MARK: - Visual Effects
    private var thrusterParticles: SKEmitterNode!
    private var glowEffect: SKEffectNode!
    private var damageSmoke: SKEmitterNode?
    
    // MARK: - Screen bounds
    private var screenSize: CGSize
    
    enum AIType: CaseIterable {
        case aggressive  // Charges directly at player
        case hunter      // Circles and hunts player
        case sniper      // Keeps distance, fires accurately
        case berserker   // Fast, erratic movement
        case guardian    // Defends area, slow but tough
    }
    
    init(screenSize: CGSize) {
        self.screenSize = screenSize
        self.aiType = AIType.allCases.randomElement()!
        
        // Set properties based on AI type
        switch aiType {
        case .aggressive:
            self.maxSpeed = 180
            self.aggressionLevel = 0.9
            self.health = 1
            self.fireInterval = 2.0
            self.weaponRange = 150
            self.changeDirectionInterval = 1.5
        case .hunter:
            self.maxSpeed = 200
            self.aggressionLevel = 0.7
            self.health = 2
            self.fireInterval = 1.5
            self.weaponRange = 200
            self.changeDirectionInterval = 2.0
        case .sniper:
            self.maxSpeed = 100
            self.aggressionLevel = 0.3
            self.health = 1
            self.fireInterval = 3.0
            self.weaponRange = 300
            self.changeDirectionInterval = 3.0
        case .berserker:
            self.maxSpeed = 250
            self.aggressionLevel = 1.0
            self.health = 1
            self.fireInterval = 1.0
            self.weaponRange = 100
            self.changeDirectionInterval = 0.8
        case .guardian:
            self.maxSpeed = 120
            self.aggressionLevel = 0.5
            self.health = 3
            self.fireInterval = 2.5
            self.weaponRange = 180
            self.changeDirectionInterval = 4.0
        }
        
        let texture = SKTexture(imageNamed: "enemy_ship")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        setupRandomSpawnPosition()
        setupPhysics()
        setupVisualEffects()
        setupAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupRandomSpawnPosition() {
        let edge = Int.random(in: 0...3)
        let margin: CGFloat = 50
        
        switch edge {
        case 0: // Top
            position = CGPoint(x: CGFloat.random(in: 0...screenSize.width), y: screenSize.height + margin)
        case 1: // Right
            position = CGPoint(x: screenSize.width + margin, y: CGFloat.random(in: 0...screenSize.height))
        case 2: // Bottom
            position = CGPoint(x: CGFloat.random(in: 0...screenSize.width), y: -margin)
        default: // Left
            position = CGPoint(x: -margin, y: CGFloat.random(in: 0...screenSize.height))
        }
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.categoryBitMask = 0x1 << 1 // enemyCategory
        physicsBody?.contactTestBitMask = 0x1 << 0 | 0x1 << 2 // player and laser
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.linearDamping = 0.2
    }
    
    private func setupVisualEffects() {
        // Red glow effect for enemy ships
        glowEffect = SKEffectNode()
        glowEffect.shouldRasterize = true
        glowEffect.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 8])
        
        let glowSprite = SKSpriteNode(texture: texture)
        glowSprite.color = .red
        glowSprite.colorBlendFactor = 0.8
        glowSprite.alpha = 0.7
        glowEffect.addChild(glowSprite)
        glowEffect.zPosition = -1
        addChild(glowEffect)
        
        // Enemy thruster particles (red/orange)
        thrusterParticles = createEnemyThrusterEffect()
        thrusterParticles.position = CGPoint(x: 0, y: size.height/2) // Opposite of player
        thrusterParticles.zPosition = -2
        addChild(thrusterParticles)
    }
    
    private func createEnemyThrusterEffect() -> SKEmitterNode {
        let particles = SKEmitterNode()
        
        particles.particleTexture = SKTexture(imageNamed: "spark")
        particles.particleLifetime = 0.4
        particles.particleBirthRate = 80
        particles.particlePositionRange = CGVector(dx: 8, dy: 4)
        particles.emissionAngleRange = CGFloat.pi / 8
        
        particles.particleSpeed = 80
        particles.particleSpeedRange = 40
        particles.emissionAngle = CGFloat.pi / 2 // Upward (behind ship)
        
        particles.particleScale = 0.25
        particles.particleScaleRange = 0.15
        particles.particleScaleSpeed = -0.6
        
        // Red/orange color sequence
        let colors = [
            SKColor.red,
            SKColor.orange,
            SKColor.yellow.withAlphaComponent(0.5),
            SKColor.clear
        ]
        let times = [0.0, 0.4, 0.8, 1.0] as [NSNumber]
        particles.particleColorSequence = SKKeyframeSequence(keyframeValues: colors, times: times)
        
        particles.particleAlpha = 0.9
        particles.particleAlphaSpeed = -2.0
        
        return particles
    }
    
    private func setupAnimations() {
        // Menacing glow pulse
        let glowPulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.6),
            SKAction.fadeAlpha(to: 1.0, duration: 0.6)
        ])
        glowEffect.run(SKAction.repeatForever(glowPulse))
        
        // Slight rotation wobble for more dynamic feel
        let wobble = SKAction.sequence([
            SKAction.rotate(byAngle: 0.1, duration: 1.0),
            SKAction.rotate(byAngle: -0.2, duration: 2.0),
            SKAction.rotate(byAngle: 0.1, duration: 1.0)
        ])
        run(SKAction.repeatForever(wobble))
    }
    
    // MARK: - AI Update
    
    func update(_ currentTime: TimeInterval, playerPosition: CGPoint) {
        updateAI(currentTime, playerPosition: playerPosition)
        updateMovement(currentTime)
        updateVisuals()
        updateCombat(currentTime, playerPosition: playerPosition)
        constrainToScreen()
    }
    
    private func updateAI(_ currentTime: TimeInterval, playerPosition: CGPoint) {
        let distanceToPlayer = distance(to: playerPosition)
        
        // Change direction periodically
        if currentTime - lastDirectionChange > changeDirectionInterval {
            chooseNewTarget(playerPosition: playerPosition, distanceToPlayer: distanceToPlayer)
            lastDirectionChange = currentTime
        }
        
        // AI-specific behavior
        switch aiType {
        case .aggressive:
            targetPosition = playerPosition
            aggressionLevel = min(1.0, 0.7 + (300 - distanceToPlayer) / 1000)
            
        case .hunter:
            // Circle around player
            let angle = atan2(position.y - playerPosition.y, position.x - playerPosition.x)
            let circleRadius: CGFloat = 150
            targetPosition = CGPoint(
                x: playerPosition.x + cos(angle + 0.5) * circleRadius,
                y: playerPosition.y + sin(angle + 0.5) * circleRadius
            )
            
        case .sniper:
            // Keep optimal distance
            let optimalDistance: CGFloat = 250
            if distanceToPlayer < optimalDistance - 50 {
                // Too close, move away
                let angle = atan2(position.y - playerPosition.y, position.x - playerPosition.x)
                targetPosition = CGPoint(
                    x: position.x + cos(angle) * 100,
                    y: position.y + sin(angle) * 100
                )
            } else if distanceToPlayer > optimalDistance + 50 {
                // Too far, move closer
                targetPosition = playerPosition
            }
            
        case .berserker:
            // Erratic, unpredictable movement
            if currentTime - lastDirectionChange > changeDirectionInterval {
                let randomAngle = CGFloat.random(in: 0...(2 * CGFloat.pi))
                let randomDistance = CGFloat.random(in: 50...200)
                targetPosition = CGPoint(
                    x: playerPosition.x + cos(randomAngle) * randomDistance,
                    y: playerPosition.y + sin(randomAngle) * randomDistance
                )
            }
            
        case .guardian:
            // Patrol behavior, but converge on player if close
            if distanceToPlayer < 200 {
                targetPosition = playerPosition
            } else {
                // Patrol pattern
                let patrolCenter = CGPoint(x: screenSize.width * 0.7, y: screenSize.height * 0.5)
                let angle = currentTime * 0.5
                targetPosition = CGPoint(
                    x: patrolCenter.x + cos(angle) * 100,
                    y: patrolCenter.y + sin(angle) * 100
                )
            }
        }
    }
    
    private func chooseNewTarget(playerPosition: CGPoint, distanceToPlayer: CGFloat) {
        // Add some randomness to make AI less predictable
        let randomOffset = CGPoint(
            x: CGFloat.random(in: -100...100),
            y: CGFloat.random(in: -100...100)
        )
        
        targetPosition.x += randomOffset.x
        targetPosition.y += randomOffset.y
        
        // Ensure target is within screen bounds
        targetPosition.x = max(50, min(screenSize.width - 50, targetPosition.x))
        targetPosition.y = max(50, min(screenSize.height - 50, targetPosition.y))
    }
    
    private func updateMovement(_ currentTime: TimeInterval) {
        let deltaX = targetPosition.x - position.x
        let deltaY = targetPosition.y - position.y
        let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
        
        if distance > 10 {
            // Normalize direction and apply speed
            let directionX = (deltaX / distance) * maxSpeed * aggressionLevel
            let directionY = (deltaY / distance) * maxSpeed * aggressionLevel
            
            velocity.dx = directionX
            velocity.dy = directionY
            
            // Apply velocity
            position.x += velocity.dx * (1.0/60.0)
            position.y += velocity.dy * (1.0/60.0)
            
            // Update thruster intensity
            thrusterParticles.particleBirthRate = 100
            
            // Rotate ship to face movement direction
            let angle = atan2(directionY, directionX) - CGFloat.pi/2
            let rotateAction = SKAction.rotate(toAngle: angle, duration: 0.3)
            run(rotateAction)
        } else {
            thrusterParticles.particleBirthRate = 30
        }
    }
    
    private func updateVisuals() {
        // Update thruster direction based on movement
        if velocity.dx != 0 || velocity.dy != 0 {
            let angle = atan2(-velocity.dx, -velocity.dy)
            thrusterParticles.emissionAngle = angle
        }
        
        // Health-based effects
        if health <= 1 && damageSmoke == nil {
            createDamageSmoke()
        }
    }
    
    private func createDamageSmoke() {
        damageSmoke = SKEmitterNode()
        damageSmoke!.particleTexture = SKTexture(imageNamed: "spark")
        damageSmoke!.particleLifetime = 2.0
        damageSmoke!.particleBirthRate = 20
        damageSmoke!.particlePositionRange = CGVector(dx: size.width * 0.5, dy: size.height * 0.5)
        damageSmoke!.particleSpeed = 30
        damageSmoke!.particleSpeedRange = 20
        damageSmoke!.particleColor = .gray
        damageSmoke!.particleColorBlendFactor = 0.8
        damageSmoke!.particleAlpha = 0.6
        damageSmoke!.particleAlphaSpeed = -0.3
        damageSmoke!.particleScale = 0.4
        damageSmoke!.particleScaleSpeed = 0.2
        damageSmoke!.zPosition = -1
        
        addChild(damageSmoke!)
    }
    
    private func updateCombat(_ currentTime: TimeInterval, playerPosition: CGPoint) {
        let distanceToPlayer = distance(to: playerPosition)
        
        // Fire at player if in range and line of sight
        if distanceToPlayer <= weaponRange && 
           currentTime - lastFireTime > fireInterval &&
           hasLineOfSight(to: playerPosition) {
            fireAtPlayer(playerPosition)
            lastFireTime = currentTime
        }
    }
    
    private func hasLineOfSight(to playerPosition: CGPoint) -> Bool {
        // Simple line of sight check (could be enhanced with obstacle detection)
        return true
    }
    
    private func fireAtPlayer(_ playerPosition: CGPoint) {
        guard let scene = scene as? GameScene3D else { return }
        
        // Calculate direction to player
        let deltaX = playerPosition.x - position.x
        let deltaY = playerPosition.y - position.y
        let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
        
        if distance > 0 {
            let direction = CGPoint(x: deltaX / distance, y: deltaY / distance)
            
            // Create enemy laser
            let laser = EnemyLaser3D(from: position, direction: direction)
            scene.addEnemyLaser(laser)
        }
    }
    
    // MARK: - Utility Methods
    
    private func distance(to point: CGPoint) -> CGFloat {
        let deltaX = position.x - point.x
        let deltaY = position.y - point.y
        return sqrt(deltaX * deltaX + deltaY * deltaY)
    }
    
    private func constrainToScreen() {
        let margin: CGFloat = 50
        position.x = max(-margin, min(screenSize.width + margin, position.x))
        position.y = max(-margin, min(screenSize.height + margin, position.y))
    }
    
    // MARK: - Combat Methods
    
    func takeDamage(_ damage: Int = 1) {
        health -= damage
        
        // Damage flash effect
        let damageFlash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.colorize(with: .red, colorBlendFactor: 0.0, duration: 0.1)
        ])
        run(damageFlash)
        
        if health <= 0 {
            destroyShip()
        }
    }
    
    private func destroyShip() {
        // Create destruction effect
        createDestructionEffect()
        
        // Remove from parent scene
        removeFromParent()
    }
    
    private func createDestructionEffect() {
        guard let scene = scene else { return }
        
        let explosion = SKEmitterNode()
        explosion.position = position
        explosion.particleTexture = SKTexture(imageNamed: "spark")
        explosion.particleLifetime = 1.0
        explosion.particleBirthRate = 300
        explosion.numParticlesToEmit = 100
        explosion.particlePositionRange = CGVector(dx: size.width, dy: size.height)
        explosion.particleSpeed = 200
        explosion.particleSpeedRange = 150
        explosion.emissionAngleRange = 2 * CGFloat.pi
        explosion.particleColor = .orange
        explosion.particleColorBlendFactor = 0.8
        explosion.particleAlpha = 0.9
        explosion.particleAlphaSpeed = -0.9
        explosion.particleScale = 0.6
        explosion.particleScaleSpeed = -0.3
        explosion.zPosition = 200
        
        scene.addChild(explosion)
        
        explosion.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.removeFromParent()
        ]))
    }
    
    func isDestroyed() -> Bool {
        return health <= 0
    }
    
    func getAIType() -> AIType {
        return aiType
    }
    
    func getHealth() -> Int {
        return health
    }
}