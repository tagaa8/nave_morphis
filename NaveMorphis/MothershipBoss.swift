import SpriteKit
import GameplayKit

class MothershipBoss: SKSpriteNode {
    
    // MARK: - Boss Properties
    private var maxHealth: Int = 100
    private var currentHealth: Int = 100
    private var phase: BossPhase = .arrival
    private var lastPhaseChange: TimeInterval = 0
    
    // MARK: - Movement Properties
    private var targetPosition = CGPoint.zero
    private var velocity = CGVector.zero
    private var maxSpeed: CGFloat = 150
    private var rotationSpeed: CGFloat = 0.02
    private var oscillationAmplitude: CGFloat = 50
    
    // MARK: - Combat Properties
    private var weapons: [WeaponModule] = []
    private var lastWeaponFire: TimeInterval = 0
    private var weaponFireInterval: TimeInterval = 1.5
    private var isInvulnerable = false
    private var invulnerabilityEnd: TimeInterval = 0
    
    // MARK: - Visual Effects
    private var coreGlow: SKEffectNode!
    private var shieldEffect: SKShapeNode?
    private var damageEffects: [SKEmitterNode] = []
    private var energyBeams: [EnergyBeam] = []
    
    // MARK: - Destructible Modules
    private var destructibleModules: [DestructibleModule] = []
    private var coreModule: CoreModule!
    
    // MARK: - Screen Properties
    private var screenSize: CGSize
    
    enum BossPhase {
        case arrival      // Initial dramatic entrance
        case phase1       // Standard attack pattern
        case phase2       // More aggressive, some modules destroyed
        case phase3       // Core exposed, desperate attacks
        case destruction  // Final explosion sequence
    }
    
    init(screenSize: CGSize) {
        self.screenSize = screenSize
        
        let texture = SKTexture(imageNamed: "mothership_or_map")
        super.init(texture: texture, color: .clear, size: CGSize(width: 300, height: 200))
        
        setupPhysics()
        setupVisualEffects()
        setupModules()
        setupAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = 0x1 << 4 // mothershipCategory
        physicsBody?.contactTestBitMask = 0x1 << 2 // laser
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
    }
    
    private func setupVisualEffects() {
        // Main core glow effect
        coreGlow = SKEffectNode()
        coreGlow.shouldRasterize = true
        coreGlow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 15])
        
        let coreSprite = SKSpriteNode(texture: texture)
        coreSprite.color = .cyan
        coreSprite.colorBlendFactor = 0.6
        coreSprite.alpha = 0.8
        coreGlow.addChild(coreSprite)
        coreGlow.zPosition = -1
        addChild(coreGlow)
        
        // Energy field around the ship
        createEnergyField()
        
        // Add some ambient lighting effects
        createAmbientLighting()
    }
    
    private func createEnergyField() {
        let energyField = SKShapeNode(rectOf: CGSize(width: size.width * 1.2, height: size.height * 1.2))
        energyField.strokeColor = .purple
        energyField.lineWidth = 2
        energyField.fillColor = .purple.withAlphaComponent(0.05)
        energyField.alpha = 0.7
        energyField.zPosition = -2
        addChild(energyField)
        
        // Pulsing energy field
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 2.0),
            SKAction.scale(to: 0.9, duration: 2.0)
        ])
        energyField.run(SKAction.repeatForever(pulse))
    }
    
    private func createAmbientLighting() {
        // Create multiple ambient light sources around the mothership
        for i in 0..<6 {
            let angle = CGFloat(i) * CGFloat.pi / 3
            let lightRadius: CGFloat = size.width * 0.6
            
            let light = SKShapeNode(circleOfRadius: 15)
            light.fillColor = .purple.withAlphaComponent(0.3)
            light.strokeColor = .clear
            light.position = CGPoint(
                x: cos(angle) * lightRadius,
                y: sin(angle) * lightRadius
            )
            light.zPosition = -1
            addChild(light)
            
            // Flickering effect
            let flicker = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.1, duration: Double.random(in: 1.0...3.0)),
                SKAction.fadeAlpha(to: 0.5, duration: Double.random(in: 1.0...3.0))
            ])
            light.run(SKAction.repeatForever(flicker))
        }
    }
    
    private func setupModules() {
        // Create destructible weapon modules around the perimeter
        let modulePositions = [
            CGPoint(x: -size.width * 0.3, y: size.height * 0.2),
            CGPoint(x: size.width * 0.3, y: size.height * 0.2),
            CGPoint(x: -size.width * 0.4, y: -size.height * 0.1),
            CGPoint(x: size.width * 0.4, y: -size.height * 0.1),
            CGPoint(x: 0, y: size.height * 0.3),
            CGPoint(x: 0, y: -size.height * 0.3)
        ]
        
        for (_, position) in modulePositions.enumerated() {
            let module = DestructibleModule(type: .weapon, health: 15)
            module.position = position
            addChild(module)
            destructibleModules.append(module)
        }
        
        // Create central core module (final target)
        coreModule = CoreModule(health: 30)
        coreModule.position = CGPoint.zero
        coreModule.isHidden = true // Hidden until other modules are destroyed
        addChild(coreModule)
        
        // Set up weapon systems
        setupWeapons()
    }
    
    private func setupWeapons() {
        for module in destructibleModules {
            let weapon = WeaponModule(
                position: module.position,
                type: .plasmaCannon,
                fireRate: Double.random(in: 1.0...3.0)
            )
            weapons.append(weapon)
        }
    }
    
    private func setupAnimations() {
        // Main rotation animation
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 20)
        run(SKAction.repeatForever(rotate))
        
        // Core glow pulsing
        let coreGlowPulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 1.5),
            SKAction.fadeAlpha(to: 1.0, duration: 1.5)
        ])
        coreGlow.run(SKAction.repeatForever(coreGlowPulse))
        
        // Entrance animation
        alpha = 0
        setScale(0.1)
        let entrance = SKAction.group([
            SKAction.fadeIn(withDuration: 3.0),
            SKAction.scale(to: 1.0, duration: 3.0)
        ])
        run(entrance)
    }
    
    // MARK: - Update Methods
    
    func update(_ currentTime: TimeInterval, playerPosition: CGPoint) {
        updatePhase(currentTime)
        updateMovement(currentTime)
        updateCombat(currentTime, playerPosition: playerPosition)
        updateVisualEffects(currentTime)
        updateModules(currentTime)
    }
    
    private func updatePhase(_ currentTime: TimeInterval) {
        let healthPercentage = Float(currentHealth) / Float(maxHealth)
        let newPhase: BossPhase
        
        switch healthPercentage {
        case 0.75...1.0:
            newPhase = .phase1
        case 0.4...0.75:
            newPhase = .phase2
        case 0.1...0.4:
            newPhase = .phase3
        default:
            newPhase = .destruction
        }
        
        if newPhase != phase {
            transitionToPhase(newPhase, currentTime: currentTime)
        }
    }
    
    private func transitionToPhase(_ newPhase: BossPhase, currentTime: TimeInterval) {
        phase = newPhase
        lastPhaseChange = currentTime
        
        switch phase {
        case .arrival:
            break
            
        case .phase1:
            weaponFireInterval = 1.5
            maxSpeed = 100
            
        case .phase2:
            weaponFireInterval = 1.0
            maxSpeed = 120
            createPhaseTransitionEffect()
            
        case .phase3:
            weaponFireInterval = 0.7
            maxSpeed = 150
            exposeCore()
            createPhaseTransitionEffect()
            
        case .destruction:
            beginDestructionSequence()
        }
    }
    
    private func createPhaseTransitionEffect() {
        // Screen flash
        guard let scene = scene else { return }
        
        let flash = SKSpriteNode(color: .red, size: scene.size)
        flash.alpha = 0.5
        flash.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        flash.zPosition = 1000
        scene.addChild(flash)
        
        flash.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
        
        // Energy explosion from mothership
        let explosion = SKEmitterNode()
        explosion.position = position
        explosion.particleTexture = SKTexture(imageNamed: "spark")
        explosion.particleLifetime = 1.5
        explosion.particleBirthRate = 200
        explosion.numParticlesToEmit = 150
        explosion.particlePositionRange = CGVector(dx: size.width, dy: size.height)
        explosion.particleSpeed = 300
        explosion.particleSpeedRange = 200
        explosion.emissionAngleRange = 2 * CGFloat.pi
        explosion.particleColor = .purple
        explosion.particleAlpha = 0.8
        explosion.particleAlphaSpeed = -0.5
        explosion.particleScale = 0.8
        explosion.particleScaleSpeed = -0.4
        explosion.zPosition = 100
        
        scene.addChild(explosion)
        
        explosion.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ]))
    }
    
    private func exposeCore() {
        coreModule.isHidden = false
        coreModule.alpha = 0
        
        let coreReveal = SKAction.sequence([
            SKAction.fadeIn(withDuration: 2.0),
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        coreModule.run(coreReveal)
    }
    
    private func updateMovement(_ currentTime: TimeInterval) {
        // Oscillating movement pattern
        let oscillation = sin(currentTime * rotationSpeed * 2) * oscillationAmplitude
        
        switch phase {
        case .arrival:
            // Stay relatively still during arrival
            break
            
        case .phase1:
            // Slow horizontal movement
            targetPosition.x = screenSize.width * 0.5 + oscillation
            targetPosition.y = screenSize.height * 0.8
            
        case .phase2:
            // More aggressive movement
            targetPosition.x = screenSize.width * 0.5 + oscillation * 1.5
            targetPosition.y = screenSize.height * 0.7
            
        case .phase3:
            // Erratic movement when core is exposed
            targetPosition.x = screenSize.width * 0.5 + sin(currentTime * 3) * 100
            targetPosition.y = screenSize.height * 0.6 + cos(currentTime * 2) * 50
            
        case .destruction:
            // Violent shaking
            targetPosition.x += CGFloat.random(in: -20...20)
            targetPosition.y += CGFloat.random(in: -20...20)
        }
        
        // Smooth movement toward target
        let deltaX = targetPosition.x - position.x
        let deltaY = targetPosition.y - position.y
        
        velocity.dx = deltaX * 0.02
        velocity.dy = deltaY * 0.02
        
        position.x += velocity.dx
        position.y += velocity.dy
    }
    
    private func updateCombat(_ currentTime: TimeInterval, playerPosition: CGPoint) {
        guard phase != .destruction else { return }
        
        // Fire weapons from active modules
        if currentTime - lastWeaponFire > weaponFireInterval {
            fireWeapons(playerPosition)
            lastWeaponFire = currentTime
        }
        
        // Special attacks based on phase
        switch phase {
        case .phase2:
            if Int.random(in: 1...100) <= 2 { // 2% chance per frame
                launchMissileSwarm(playerPosition)
            }
            
        case .phase3:
            if Int.random(in: 1...100) <= 3 { // 3% chance per frame
                fireEnergyBeam(playerPosition)
            }
            
        default:
            break
        }
    }
    
    private func fireWeapons(_ playerPosition: CGPoint) {
        guard let scene = scene as? GameScene3D else { return }
        
        for weapon in weapons where weapon.isActive {
            let deltaX = playerPosition.x - (position.x + weapon.position.x)
            let deltaY = playerPosition.y - (position.y + weapon.position.y)
            let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
            
            if distance > 0 {
                let direction = CGPoint(x: deltaX / distance, y: deltaY / distance)
                
                let laser = EnemyLaser3D(
                    from: CGPoint(x: position.x + weapon.position.x, y: position.y + weapon.position.y),
                    direction: direction
                )
                laser.setScale(1.5) // Bigger lasers from mothership
                scene.addEnemyLaser(laser)
            }
        }
    }
    
    private func launchMissileSwarm(_ playerPosition: CGPoint) {
        // Launch multiple homing missiles
        for i in 0..<5 {
            let angle = CGFloat(i) * CGFloat.pi * 0.4 - CGFloat.pi * 0.8
            let startPosition = CGPoint(
                x: position.x + cos(angle) * size.width * 0.4,
                y: position.y + sin(angle) * size.height * 0.4
            )
            
            let missile = HomingMissile(from: startPosition, target: playerPosition)
            scene?.addChild(missile)
        }
    }
    
    private func fireEnergyBeam(_ playerPosition: CGPoint) {
        let beam = EnergyBeam(from: position, to: playerPosition)
        energyBeams.append(beam)
        addChild(beam)
        
        // Remove beam after duration
        beam.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ])) { [weak self] in
            if let index = self?.energyBeams.firstIndex(of: beam) {
                self?.energyBeams.remove(at: index)
            }
        }
    }
    
    private func updateVisualEffects(_ currentTime: TimeInterval) {
        // Health-based damage effects
        let healthPercentage = Float(currentHealth) / Float(maxHealth)
        
        if healthPercentage < 0.5 && damageEffects.isEmpty {
            createDamageEffects()
        }
        
        // Update invulnerability effect
        if isInvulnerable && currentTime > invulnerabilityEnd {
            isInvulnerable = false
            alpha = 1.0
        }
    }
    
    private func createDamageEffects() {
        // Add smoke and sparks for damaged state
        for _ in 0..<3 {
            let smoke = SKEmitterNode()
            smoke.particleTexture = SKTexture(imageNamed: "spark")
            smoke.particleLifetime = 3.0
            smoke.particleBirthRate = 15
            smoke.particlePositionRange = CGVector(dx: size.width * 0.3, dy: size.height * 0.3)
            smoke.particleSpeed = 50
            smoke.particleSpeedRange = 30
            smoke.particleColor = .gray
            smoke.particleAlpha = 0.7
            smoke.particleAlphaSpeed = -0.2
            smoke.particleScale = 0.6
            smoke.particleScaleSpeed = 0.1
            
            smoke.position = CGPoint(
                x: CGFloat.random(in: -size.width * 0.3...size.width * 0.3),
                y: CGFloat.random(in: -size.height * 0.3...size.height * 0.3)
            )
            smoke.zPosition = 1
            
            addChild(smoke)
            damageEffects.append(smoke)
        }
    }
    
    private func updateModules(_ currentTime: TimeInterval) {
        // Check for destroyed modules
        destructibleModules.removeAll { module in
            if module.isDestroyed {
                module.removeFromParent()
                
                // Deactivate corresponding weapon
                if let index = destructibleModules.firstIndex(of: module),
                   index < weapons.count {
                    weapons[index].isActive = false
                }
                
                createModuleExplosion(at: module.position)
                return true
            }
            return false
        }
        
        // Check if all modules destroyed and core should be exposed
        if destructibleModules.isEmpty && coreModule.isHidden {
            exposeCore()
        }
    }
    
    private func createModuleExplosion(at position: CGPoint) {
        let explosion = SKEmitterNode()
        explosion.position = CGPoint(x: self.position.x + position.x, y: self.position.y + position.y)
        explosion.particleTexture = SKTexture(imageNamed: "spark")
        explosion.particleLifetime = 1.2
        explosion.particleBirthRate = 100
        explosion.numParticlesToEmit = 80
        explosion.particlePositionRange = CGVector(dx: 40, dy: 40)
        explosion.particleSpeed = 150
        explosion.particleSpeedRange = 100
        explosion.emissionAngleRange = 2 * CGFloat.pi
        explosion.particleColor = .orange
        explosion.particleAlpha = 0.9
        explosion.particleAlphaSpeed = -0.8
        explosion.particleScale = 0.7
        explosion.particleScaleSpeed = -0.4
        explosion.zPosition = 200
        
        scene?.addChild(explosion)
        
        explosion.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.removeFromParent()
        ]))
    }
    
    // MARK: - Damage System
    
    func takeDamage(_ damage: Int) {
        guard !isInvulnerable else { return }
        
        currentHealth -= damage
        
        // Damage flash
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.colorize(with: .purple, colorBlendFactor: 0.0, duration: 0.1)
        ])
        run(flash)
        
        // Brief invulnerability
        isInvulnerable = true
        invulnerabilityEnd = CACurrentMediaTime() + 0.2
        
        let invulnFlash = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        run(invulnFlash)
        
        if currentHealth <= 0 {
            beginDestructionSequence()
        }
    }
    
    private func beginDestructionSequence() {
        phase = .destruction
        
        // Stop all weapons
        weapons.forEach { $0.isActive = false }
        
        // Create massive explosion effect
        createFinalExplosion()
        
        // Remove after explosion
        let destructionDelay = SKAction.wait(forDuration: 5.0)
        let removeAction = SKAction.removeFromParent()
        run(SKAction.sequence([destructionDelay, removeAction]))
    }
    
    private func createFinalExplosion() {
        guard let scene = scene else { return }
        
        // Multiple explosion waves
        for i in 0..<5 {
            let delay = Double(i) * 0.8
            
            run(SKAction.wait(forDuration: delay)) { [weak self] in
                guard let self = self else { return }
                
                let explosion = SKEmitterNode()
                explosion.position = self.position
                explosion.particleTexture = SKTexture(imageNamed: "spark")
                explosion.particleLifetime = 2.0
                explosion.particleBirthRate = 500
                explosion.numParticlesToEmit = 300
                explosion.particlePositionRange = CGVector(dx: self.size.width * 1.5, dy: self.size.height * 1.5)
                explosion.particleSpeed = 400
                explosion.particleSpeedRange = 300
                explosion.emissionAngleRange = 2 * CGFloat.pi
                explosion.particleColor = [.orange, .red, .yellow, .white].randomElement()!
                explosion.particleAlpha = 1.0
                explosion.particleAlphaSpeed = -0.5
                explosion.particleScale = 1.2
                explosion.particleScaleSpeed = -0.6
                explosion.zPosition = 500
                
                scene.addChild(explosion)
                
                explosion.run(SKAction.sequence([
                    SKAction.wait(forDuration: 3.0),
                    SKAction.removeFromParent()
                ]))
            }
        }
    }
    
    // MARK: - Properties
    
    var isDestroyed: Bool {
        return currentHealth <= 0 || phase == .destruction
    }
    
    var healthPercentage: Float {
        return Float(currentHealth) / Float(maxHealth)
    }
    
    var currentPhase: BossPhase {
        return phase
    }
}

// MARK: - Supporting Classes

class DestructibleModule: SKSpriteNode {
    private var health: Int
    private var maxHealth: Int
    private let moduleType: ModuleType
    
    enum ModuleType {
        case weapon, shield, sensor
    }
    
    init(type: ModuleType, health: Int) {
        self.moduleType = type
        self.health = health
        self.maxHealth = health
        
        let texture = SKTexture(imageNamed: "spark") // Using spark as placeholder
        super.init(texture: texture, color: .purple, size: CGSize(width: 30, height: 30))
        
        colorBlendFactor = 0.8
        setupPhysics()
        setupVisualEffects()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = 0x1 << 4 // mothershipCategory
        physicsBody?.contactTestBitMask = 0x1 << 2 // laser
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = false
    }
    
    private func setupVisualEffects() {
        let glow = SKEffectNode()
        glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 5])
        
        let glowSprite = SKSpriteNode(texture: texture, size: size)
        glowSprite.color = .purple
        glowSprite.colorBlendFactor = 1.0
        glowSprite.alpha = 0.6
        glow.addChild(glowSprite)
        glow.zPosition = -1
        addChild(glow)
    }
    
    func takeDamage(_ damage: Int = 1) {
        health -= damage
        
        // Visual damage indication
        let healthPercentage = Float(health) / Float(maxHealth)
        alpha = CGFloat(healthPercentage)
        
        let damageFlash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.1),
            SKAction.colorize(with: .purple, colorBlendFactor: 0.8, duration: 0.1)
        ])
        run(damageFlash)
    }
    
    var isDestroyed: Bool {
        return health <= 0
    }
}

class CoreModule: SKSpriteNode {
    private var health: Int
    private var maxHealth: Int
    
    init(health: Int) {
        self.health = health
        self.maxHealth = health
        
        let texture = SKTexture(imageNamed: "spark")
        super.init(texture: texture, color: .cyan, size: CGSize(width: 40, height: 40))
        
        colorBlendFactor = 1.0
        setupPhysics()
        setupVisualEffects()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        physicsBody?.categoryBitMask = 0x1 << 4 // mothershipCategory
        physicsBody?.contactTestBitMask = 0x1 << 2 // laser
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = false
    }
    
    private func setupVisualEffects() {
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])
        run(SKAction.repeatForever(pulse))
        
        let colorShift = SKAction.sequence([
            SKAction.colorize(with: .cyan, colorBlendFactor: 1.0, duration: 1.0),
            SKAction.colorize(with: .magenta, colorBlendFactor: 1.0, duration: 1.0)
        ])
        run(SKAction.repeatForever(colorShift))
    }
    
    func takeDamage(_ damage: Int = 1) {
        health -= damage
        
        let damageFlash = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.1),
            SKAction.colorize(with: .cyan, colorBlendFactor: 1.0, duration: 0.1)
        ])
        run(damageFlash)
    }
    
    var isDestroyed: Bool {
        return health <= 0
    }
}

class WeaponModule {
    let position: CGPoint
    let type: WeaponType
    let fireRate: TimeInterval
    var isActive: Bool = true
    
    enum WeaponType {
        case plasmaCannon, missileLauncher, energyBeam
    }
    
    init(position: CGPoint, type: WeaponType, fireRate: TimeInterval) {
        self.position = position
        self.type = type
        self.fireRate = fireRate
    }
}

class HomingMissile: SKSpriteNode {
    private var targetPosition: CGPoint
    private var velocity = CGVector.zero
    private var maxSpeed: CGFloat = 200
    private var turnRate: CGFloat = 0.05
    
    init(from startPosition: CGPoint, target: CGPoint) {
        self.targetPosition = target
        
        let texture = SKTexture(imageNamed: "spark")
        super.init(texture: texture, color: .red, size: CGSize(width: 8, height: 16))
        
        position = startPosition
        colorBlendFactor = 1.0
        setupPhysics()
        setupTrail()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = 0x1 << 1 // enemyCategory (treat as enemy projectile)
        physicsBody?.contactTestBitMask = 0x1 << 0 // player
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
    }
    
    private func setupTrail() {
        let trail = SKEmitterNode()
        trail.particleTexture = SKTexture(imageNamed: "spark")
        trail.particleLifetime = 0.5
        trail.particleBirthRate = 50
        trail.particleSpeed = 30
        trail.particleColor = .red
        trail.particleAlpha = 0.8
        trail.particleAlphaSpeed = -1.6
        trail.particleScale = 0.3
        trail.particleScaleSpeed = -0.3
        trail.emissionAngle = CGFloat.pi
        trail.emissionAngleRange = CGFloat.pi / 6
        
        addChild(trail)
    }
}

class EnergyBeam: SKSpriteNode {
    init(from startPoint: CGPoint, to endPoint: CGPoint) {
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
        let angle = atan2(deltaY, deltaX)
        
        super.init(texture: nil, color: .purple, size: CGSize(width: distance, height: 8))
        
        position = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
        zRotation = angle
        alpha = 0.8
        
        setupEffects()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupEffects() {
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        run(SKAction.repeat(pulse, count: 10))
    }
}