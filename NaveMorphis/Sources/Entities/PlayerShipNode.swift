import SpriteKit
import CoreGraphics

class PlayerShipNode: SKSpriteNode {
    
    var health: CGFloat = GameConfig.Player.maxHealth
    var shield: CGFloat = GameConfig.Player.maxShield
    var energy: CGFloat = GameConfig.Player.maxEnergy
    var velocity: CGVector = CGVector.zero
    var lastFireTime: TimeInterval = 0
    var isInvulnerable: Bool = false
    var invulnerabilityEndTime: TimeInterval = 0
    
    private var thrustParticles: SKEmitterNode?
    private var shieldNode: SKShapeNode?
    private var trailNodes: [SKSpriteNode] = []
    private var healthBar: SKShapeNode?
    private var shieldBar: SKShapeNode?
    private var energyBar: SKShapeNode?
    
    var powerUps: [PowerUpType: TimeInterval] = [:]
    var isMorphed: Bool = false
    var isTurboActive: Bool = false
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        setupPhysics()
        setupVisuals()
        setupBars()
    }
    
    convenience init() {
        let texture = SKTexture(imageNamed: "player_ship")
        self.init(texture: texture, color: .clear, size: CGSize(width: 60, height: 60))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = PhysicsHelper.createCircleBody(radius: size.width / 2)
        PhysicsHelper.configureBody(
            for: physicsBody!,
            category: PhysicsCategory.player,
            contact: PhysicsCategory.enemy | PhysicsCategory.laserEnemy | PhysicsCategory.powerUp | PhysicsCategory.mothership,
            collision: PhysicsCategory.boundary
        )
        physicsBody?.mass = 1.0
        physicsBody?.linearDamping = 2.0
        physicsBody?.angularDamping = 3.0
    }
    
    private func setupVisuals() {
        colorBlendFactor = 0.3
        color = .cyan
        
        setupThrustParticles()
        setupShield()
        setupTrail()
    }
    
    private func setupThrustParticles() {
        thrustParticles = SKEmitterNode()
        thrustParticles?.particleTexture = SKTexture(imageNamed: "spark")
        thrustParticles?.particleBirthRate = 50
        thrustParticles?.particleLifetime = 0.8
        thrustParticles?.particleLifetimeRange = 0.2
        thrustParticles?.emissionAngle = CGFloat.pi
        thrustParticles?.emissionAngleRange = CGFloat.pi / 4
        thrustParticles?.particleSpeed = 100
        thrustParticles?.particleSpeedRange = 30
        thrustParticles?.particleScale = 0.5
        thrustParticles?.particleScaleRange = 0.2
        thrustParticles?.particleColorBlue = 1.0
        thrustParticles?.particleColorGreen = 0.5
        thrustParticles?.particleColorRed = 0.0
        thrustParticles?.particleAlpha = 0.8
        thrustParticles?.particleAlphaRange = 0.3
        thrustParticles?.position = CGPoint(x: 0, y: -size.height / 2)
        
        if let thrustParticles = thrustParticles {
            addChild(thrustParticles)
        }
    }
    
    private func setupShield() {
        shieldNode = SKShapeNode(circleOfRadius: size.width / 2 + 10)
        shieldNode?.strokeColor = .cyan
        shieldNode?.lineWidth = 3
        shieldNode?.fillColor = .clear
        shieldNode?.alpha = 0
        shieldNode?.glowWidth = 5
        
        if let shieldNode = shieldNode {
            addChild(shieldNode)
        }
    }
    
    private func setupTrail() {
        for i in 0..<GameConfig.Visual.trailLength {
            let trail = SKSpriteNode(texture: texture, size: CGSize(width: size.width * 0.8, height: size.height * 0.8))
            trail.alpha = 0
            trail.colorBlendFactor = 1.0
            trail.color = .cyan
            trail.zPosition = -1
            trailNodes.append(trail)
            parent?.addChild(trail)
        }
    }
    
    private func setupBars() {
        let barWidth: CGFloat = 40
        let barHeight: CGFloat = 4
        let yOffset: CGFloat = size.height / 2 + 15
        
        healthBar = createBar(width: barWidth, height: barHeight, color: .red, position: CGPoint(x: 0, y: yOffset))
        shieldBar = createBar(width: barWidth, height: barHeight, color: .blue, position: CGPoint(x: 0, y: yOffset + 8))
        energyBar = createBar(width: barWidth, height: barHeight, color: .yellow, position: CGPoint(x: 0, y: yOffset + 16))
        
        if let healthBar = healthBar, let shieldBar = shieldBar, let energyBar = energyBar {
            addChild(healthBar)
            addChild(shieldBar)
            addChild(energyBar)
        }
    }
    
    private func createBar(width: CGFloat, height: CGFloat, color: UIColor, position: CGPoint) -> SKShapeNode {
        let bar = SKShapeNode(rectOf: CGSize(width: width, height: height))
        bar.fillColor = color
        bar.strokeColor = .clear
        bar.position = position
        bar.alpha = 0.8
        return bar
    }
    
    func update(deltaTime: TimeInterval) {
        updatePowerUps(deltaTime: deltaTime)
        updateEnergy(deltaTime: deltaTime)
        updateInvulnerability(deltaTime: deltaTime)
        updateTrail()
        updateBars()
        updateThrustParticles()
    }
    
    private func updatePowerUps(deltaTime: TimeInterval) {
        let currentTime = CACurrentMediaTime()
        var expiredPowerUps: [PowerUpType] = []
        
        for (type, endTime) in powerUps {
            if currentTime > endTime {
                expiredPowerUps.append(type)
            }
        }
        
        for type in expiredPowerUps {
            powerUps.removeValue(forKey: type)
            removePowerUpEffect(type)
        }
        
        if isTurboActive && currentTime > (powerUps[.turbo] ?? 0) {
            isTurboActive = false
        }
        
        if isMorphed && currentTime > (powerUps[.morph] ?? 0) {
            isMorphed = false
            resetMorphVisuals()
        }
    }
    
    private func updateEnergy(deltaTime: TimeInterval) {
        if energy < GameConfig.Player.maxEnergy {
            energy = min(GameConfig.Player.maxEnergy, energy + GameConfig.Player.energyRegenRate * CGFloat(deltaTime))
        }
    }
    
    private func updateInvulnerability(deltaTime: TimeInterval) {
        if isInvulnerable {
            let currentTime = CACurrentMediaTime()
            if currentTime > invulnerabilityEndTime {
                isInvulnerable = false
                alpha = 1.0
            } else {
                alpha = sin(currentTime * 20) * 0.5 + 0.5
            }
        }
    }
    
    private func updateTrail() {
        for (index, trail) in trailNodes.enumerated() {
            let delay = Double(index + 1) * 0.05
            let targetPosition = position
            let targetAlpha: CGFloat = isTurboActive ? 0.8 : 0.3
            
            trail.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([
                    SKAction.move(to: targetPosition, duration: 0.1),
                    SKAction.fadeAlpha(to: targetAlpha * CGFloat(GameConfig.Visual.trailLength - index) / CGFloat(GameConfig.Visual.trailLength), duration: 0.1)
                ])
            ]))
        }
    }
    
    private func updateBars() {
        healthBar?.xScale = health / GameConfig.Player.maxHealth
        shieldBar?.xScale = shield / GameConfig.Player.maxShield
        energyBar?.xScale = energy / GameConfig.Player.maxEnergy
    }
    
    private func updateThrustParticles() {
        let isMoving = velocity.dx != 0 || velocity.dy != 0
        thrustParticles?.particleBirthRate = isMoving ? (isTurboActive ? 100 : 50) : 0
        
        if isTurboActive {
            thrustParticles?.particleColorRed = 1.0
            thrustParticles?.particleColorGreen = 0.3
            thrustParticles?.particleColorBlue = 0.0
        } else {
            thrustParticles?.particleColorRed = 0.0
            thrustParticles?.particleColorGreen = 0.5
            thrustParticles?.particleColorBlue = 1.0
        }
    }
    
    func applyMovement(_ movement: CGVector, deltaTime: TimeInterval) {
        let speed = isTurboActive ? GameConfig.Player.speed * GameConfig.Player.turboSpeedMultiplier : GameConfig.Player.speed
        velocity = CGVector(dx: movement.dx * speed, dy: movement.dy * speed)
        
        if movement.dx != 0 || movement.dy != 0 {
            let angle = atan2(movement.dy, movement.dx) - CGFloat.pi / 2
            zRotation = angle
        }
        
        position = CGPoint(
            x: position.x + velocity.dx * CGFloat(deltaTime),
            y: position.y + velocity.dy * CGFloat(deltaTime)
        )
    }
    
    func canFire() -> Bool {
        let currentTime = CACurrentMediaTime()
        let fireRate = hasPowerUp(.rapidFire) ? GameConfig.Player.fireRate * GameConfig.PowerUp.fireRateMultiplier : GameConfig.Player.fireRate
        return currentTime - lastFireTime >= fireRate && energy >= 5
    }
    
    func fire() -> [LaserNode] {
        guard canFire() else { return [] }
        
        lastFireTime = CACurrentMediaTime()
        energy -= 5
        
        var lasers: [LaserNode] = []
        
        if isMorphed {
            lasers.append(contentsOf: createMorphedLasers())
        } else {
            let laser = createLaser(offset: CGVector.zero)
            lasers.append(laser)
        }
        
        HapticManager.shared.playLaser()
        SoundManager.shared.playSound(.laserFire)
        
        return lasers
    }
    
    private func createLaser(offset: CGVector) -> LaserNode {
        let laser = LaserNode(isPlayerLaser: true)
        laser.position = CGPoint(
            x: position.x + offset.dx,
            y: position.y + size.height / 2 + offset.dy
        )
        laser.zRotation = zRotation
        
        let damage = hasPowerUp(.damage) ? GameConfig.Player.laserDamage * GameConfig.PowerUp.damageMultiplier : GameConfig.Player.laserDamage
        laser.damage = damage
        
        return laser
    }
    
    private func createMorphedLasers() -> [LaserNode] {
        var lasers: [LaserNode] = []
        
        let centerLaser = createLaser(offset: CGVector.zero)
        lasers.append(centerLaser)
        
        let leftLaser = createLaser(offset: CGVector(dx: -15, dy: 0))
        leftLaser.zRotation += CGFloat.pi / 12
        lasers.append(leftLaser)
        
        let rightLaser = createLaser(offset: CGVector(dx: 15, dy: 0))
        rightLaser.zRotation -= CGFloat.pi / 12
        lasers.append(rightLaser)
        
        return lasers
    }
    
    func takeDamage(_ damage: CGFloat) {
        guard !isInvulnerable else { return }
        
        if shield > 0 {
            let shieldDamage = min(shield, damage)
            shield -= shieldDamage
            let remainingDamage = damage - shieldDamage
            
            if remainingDamage > 0 {
                health -= remainingDamage
            }
            
            if shield <= 0 {
                shieldNode?.alpha = 0
            }
        } else {
            health -= damage
        }
        
        health = max(0, health)
        
        HapticManager.shared.playDamage()
        SoundManager.shared.playSound(.playerDamage)
        
        createDamageEffect()
        
        if health <= 0 {
            destroy()
        }
    }
    
    func heal(_ amount: CGFloat) {
        health = min(GameConfig.Player.maxHealth, health + amount)
        SoundManager.shared.playSound(.powerUpCollect)
        createHealEffect()
    }
    
    func restoreShield(_ amount: CGFloat) {
        shield = min(GameConfig.Player.maxShield, shield + amount)
        if shield > 0 {
            shieldNode?.alpha = 0.5
        }
    }
    
    func restoreEnergy(_ amount: CGFloat) {
        energy = min(GameConfig.Player.maxEnergy, energy + amount)
    }
    
    func applyPowerUp(_ type: PowerUpType) {
        let currentTime = CACurrentMediaTime()
        powerUps[type] = currentTime + GameConfig.PowerUp.duration
        
        switch type {
        case .turbo:
            isTurboActive = true
        case .morph:
            isMorphed = true
            applyMorphVisuals()
        case .shield:
            restoreShield(GameConfig.Player.maxShield)
        default:
            break
        }
        
        HapticManager.shared.playPowerUp()
        SoundManager.shared.playSound(.powerUpCollect)
    }
    
    func hasPowerUp(_ type: PowerUpType) -> Bool {
        return powerUps[type] != nil
    }
    
    private func removePowerUpEffect(_ type: PowerUpType) {
        
    }
    
    private func applyMorphVisuals() {
        colorBlendFactor = 1.0
        color = .magenta
        
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        run(SKAction.repeatForever(pulse))
    }
    
    private func resetMorphVisuals() {
        removeAllActions()
        colorBlendFactor = 0.3
        color = .cyan
        xScale = 1.0
        yScale = 1.0
    }
    
    private func createDamageEffect() {
        let flash = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.8, duration: GameConfig.Visual.damageFlashDuration),
            SKAction.colorize(with: .cyan, colorBlendFactor: 0.3, duration: GameConfig.Visual.damageFlashDuration)
        ])
        run(flash)
    }
    
    private func createHealEffect() {
        let flash = SKAction.sequence([
            SKAction.colorize(with: .green, colorBlendFactor: 0.8, duration: 0.2),
            SKAction.colorize(with: .cyan, colorBlendFactor: 0.3, duration: 0.2)
        ])
        run(flash)
    }
    
    private func destroy() {
        SoundManager.shared.playSound(.playerExplosion)
        HapticManager.shared.playExplosion()
        
        let explosion = createExplosionEffect()
        parent?.addChild(explosion)
        
        removeFromParent()
    }
    
    private func createExplosionEffect() -> SKEmitterNode {
        let explosion = SKEmitterNode()
        explosion.particleTexture = SKTexture(imageNamed: "spark")
        explosion.particleBirthRate = GameConfig.Visual.explosionParticles
        explosion.numParticlesToEmit = GameConfig.Visual.explosionParticles
        explosion.particleLifetime = 2.0
        explosion.particleLifetimeRange = 1.0
        explosion.emissionAngleRange = CGFloat.pi * 2
        explosion.particleSpeed = 200
        explosion.particleSpeedRange = 100
        explosion.particleScale = 1.0
        explosion.particleScaleRange = 0.5
        explosion.particleColorRed = 1.0
        explosion.particleColorGreen = 0.5
        explosion.particleColorBlue = 0.0
        explosion.particleAlpha = 1.0
        explosion.particleAlphaSpeed = -0.5
        explosion.position = position
        
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.removeFromParent()
        ])
        explosion.run(removeAction)
        
        return explosion
    }
    
    func makeInvulnerable(duration: TimeInterval = GameConfig.Player.respawnInvulnerability) {
        isInvulnerable = true
        invulnerabilityEndTime = CACurrentMediaTime() + duration
    }
}

enum PowerUpType: CaseIterable {
    case health, energy, shield, damage, rapidFire, turbo, morph
}