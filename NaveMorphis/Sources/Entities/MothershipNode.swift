import SpriteKit

class MothershipModule: SKSpriteNode {
    var health: CGFloat = GameConfig.Mothership.moduleHealth
    var maxHealth: CGFloat = GameConfig.Mothership.moduleHealth
    var isDestroyed: Bool = false
    private var healthBar: SKShapeNode?
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        setupModule()
    }
    
    convenience init(moduleType: String) {
        let size = CGSize(width: 80, height: 60)
        self.init(texture: nil, color: .darkGray, size: size)
        setupPhysics()
        setupHealthBar()
        setupVisuals()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupModule() {
        colorBlendFactor = 0.3
    }
    
    private func setupPhysics() {
        physicsBody = PhysicsHelper.createRectangleBody(size: size)
        PhysicsHelper.configureBody(
            for: physicsBody!,
            category: PhysicsCategory.mothership,
            contact: PhysicsCategory.laserPlayer,
            collision: PhysicsCategory.none
        )
        physicsBody?.isDynamic = false
    }
    
    private func setupHealthBar() {
        let barWidth: CGFloat = size.width
        let barHeight: CGFloat = 4
        
        let background = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        background.fillColor = .darkGray
        background.strokeColor = .clear
        background.position = CGPoint(x: 0, y: size.height / 2 + 8)
        background.alpha = 0.8
        addChild(background)
        
        healthBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        healthBar?.fillColor = .red
        healthBar?.strokeColor = .clear
        healthBar?.position = CGPoint(x: 0, y: size.height / 2 + 8)
        healthBar?.alpha = 0.8
        
        if let healthBar = healthBar {
            addChild(healthBar)
        }
    }
    
    private func setupVisuals() {
        let glow = SKSpriteNode(texture: nil, color: .red, size: CGSize(width: size.width + 10, height: size.height + 10))
        glow.alpha = 0.3
        glow.blendMode = .add
        glow.zPosition = -1
        addChild(glow)
        
        let pulseAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.1, duration: 1.0),
            SKAction.fadeAlpha(to: 0.5, duration: 1.0)
        ])
        glow.run(SKAction.repeatForever(pulseAction))
    }
    
    func takeDamage(_ damage: CGFloat) -> Bool {
        guard !isDestroyed else { return false }
        
        health -= damage
        health = max(0, health)
        
        updateHealthBar()
        createDamageEffect()
        
        if health <= 0 {
            destroy()
            return true
        }
        
        return false
    }
    
    private func updateHealthBar() {
        let healthPercentage = health / maxHealth
        healthBar?.xScale = healthPercentage
        
        if healthPercentage > 0.6 {
            healthBar?.fillColor = .green
        } else if healthPercentage > 0.3 {
            healthBar?.fillColor = .yellow
        } else {
            healthBar?.fillColor = .red
        }
    }
    
    private func createDamageEffect() {
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.colorize(with: .darkGray, colorBlendFactor: 0.3, duration: 0.1)
        ])
        run(flash)
        
        let sparks = SKEmitterNode()
        sparks.particleTexture = SKTexture(imageNamed: "spark")
        sparks.particleBirthRate = 50
        sparks.numParticlesToEmit = 15
        sparks.particleLifetime = 0.8
        sparks.particleLifetimeRange = 0.3
        sparks.emissionAngleRange = CGFloat.pi * 2
        sparks.particleSpeed = 120
        sparks.particleSpeedRange = 60
        sparks.particleScale = 0.5
        sparks.particleScaleRange = 0.3
        sparks.particleAlpha = 1.0
        sparks.particleAlphaSpeed = -1.25
        sparks.particleColorRed = 1.0
        sparks.particleColorGreen = 0.8
        sparks.particleColorBlue = 0.0
        
        addChild(sparks)
        
        let removeSparks = SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ])
        sparks.run(removeSparks)
    }
    
    private func destroy() {
        isDestroyed = true
        
        let explosion = createExplosionEffect()
        parent?.addChild(explosion)
        
        let destroyEffect = SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.scale(to: 0, duration: 0.5)
            ]),
            SKAction.removeFromParent()
        ])
        run(destroyEffect)
        
        SoundManager.shared.playSound(.moduleDestroyed)
    }
    
    private func createExplosionEffect() -> SKEmitterNode {
        let explosion = SKEmitterNode()
        explosion.particleTexture = SKTexture(imageNamed: "spark")
        explosion.particleBirthRate = 150
        explosion.numParticlesToEmit = 50
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
}

class MothershipNode: SKSpriteNode {
    
    var health: CGFloat = GameConfig.Mothership.health
    var maxHealth: CGFloat = GameConfig.Mothership.health
    var isEnraged: Bool = false
    var modules: [MothershipModule] = []
    var activeModules: Int { return modules.filter { !$0.isDestroyed }.count }
    
    private var target: PlayerShipNode?
    private var lastFireTime: TimeInterval = 0
    private var lastMissileTime: TimeInterval = 0
    private var lastBeamTime: TimeInterval = 0
    private var healthBar: SKShapeNode?
    private var coreNode: SKSpriteNode?
    private var beamCharging: Bool = false
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        setupMothership()
    }
    
    convenience init() {
        let texture = SKTexture(imageNamed: "mothership_or_map")
        let size = CGSize(width: 400, height: 300)
        self.init(texture: texture, color: .clear, size: size)
        setupPhysics()
        setupVisuals()
        setupModules()
        setupHealthBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMothership() {
        colorBlendFactor = 0.2
        color = .purple
    }
    
    private func setupPhysics() {
        physicsBody = PhysicsHelper.createRectangleBody(size: size)
        PhysicsHelper.configureBody(
            for: physicsBody!,
            category: PhysicsCategory.mothership,
            contact: PhysicsCategory.laserPlayer | PhysicsCategory.player,
            collision: PhysicsCategory.none
        )
        physicsBody?.isDynamic = false
    }
    
    private func setupVisuals() {
        setupCore()
        setupGlow()
    }
    
    private func setupCore() {
        coreNode = SKSpriteNode(texture: nil, color: .cyan, size: CGSize(width: 80, height: 80))
        coreNode?.position = CGPoint.zero
        coreNode?.colorBlendFactor = 1.0
        coreNode?.alpha = 0.8
        
        let coreGlow = SKSpriteNode(texture: nil, color: .cyan, size: CGSize(width: 100, height: 100))
        coreGlow.alpha = 0.3
        coreGlow.blendMode = .add
        coreGlow.zPosition = -1
        coreNode?.addChild(coreGlow)
        
        if let coreNode = coreNode {
            addChild(coreNode)
        }
        
        let pulseCoreAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.8),
            SKAction.scale(to: 0.9, duration: 0.8)
        ])
        coreNode?.run(SKAction.repeatForever(pulseCoreAction))
    }
    
    private func setupGlow() {
        let outerGlow = SKSpriteNode(texture: nil, color: .purple, size: CGSize(width: size.width + 20, height: size.height + 20))
        outerGlow.alpha = 0.2
        outerGlow.blendMode = .add
        outerGlow.zPosition = -2
        addChild(outerGlow)
        
        let glowPulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.1, duration: 1.5),
            SKAction.fadeAlpha(to: 0.4, duration: 1.5)
        ])
        outerGlow.run(SKAction.repeatForever(glowPulse))
    }
    
    private func setupModules() {
        let positions = [
            CGPoint(x: -150, y: 80),
            CGPoint(x: 150, y: 80),
            CGPoint(x: -150, y: -80),
            CGPoint(x: 150, y: -80)
        ]
        
        for (index, position) in positions.enumerated() {
            let module = MothershipModule(moduleType: "turret_\(index)")
            module.position = position
            modules.append(module)
            addChild(module)
        }
    }
    
    private func setupHealthBar() {
        let barWidth: CGFloat = size.width * 0.8
        let barHeight: CGFloat = 8
        
        let background = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        background.fillColor = .darkGray
        background.strokeColor = .white
        background.lineWidth = 2
        background.position = CGPoint(x: 0, y: size.height / 2 + 20)
        background.alpha = 0.8
        addChild(background)
        
        healthBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        healthBar?.fillColor = .red
        healthBar?.strokeColor = .clear
        healthBar?.position = CGPoint(x: 0, y: size.height / 2 + 20)
        healthBar?.alpha = 0.8
        
        if let healthBar = healthBar {
            addChild(healthBar)
        }
    }
    
    func setTarget(_ target: PlayerShipNode) {
        self.target = target
    }
    
    func update(deltaTime: TimeInterval) {
        guard let target = target else { return }
        
        updateHealthBar()
        updateEnrageState()
        updateBehavior(target: target, deltaTime: deltaTime)
        updateVisuals()
    }
    
    private func updateHealthBar() {
        let healthPercentage = health / maxHealth
        healthBar?.xScale = healthPercentage
        
        if healthPercentage > 0.6 {
            healthBar?.fillColor = .green
        } else if healthPercentage > 0.3 {
            healthBar?.fillColor = .yellow
        } else {
            healthBar?.fillColor = .red
        }
    }
    
    private func updateEnrageState() {
        let healthPercentage = health / maxHealth
        let modulePercentage = CGFloat(activeModules) / CGFloat(GameConfig.Mothership.moduleCount)
        
        if (healthPercentage <= GameConfig.Mothership.enrageHealthThreshold || modulePercentage <= 0.5) && !isEnraged {
            isEnraged = true
            enterEnrageMode()
        }
    }
    
    private func enterEnrageMode() {
        color = .red
        colorBlendFactor = 0.5
        
        coreNode?.color = .red
        
        let shakeAction = SKAction.sequence([
            SKAction.moveBy(x: -5, y: 0, duration: 0.1),
            SKAction.moveBy(x: 10, y: 0, duration: 0.1),
            SKAction.moveBy(x: -5, y: 0, duration: 0.1)
        ])
        run(SKAction.repeatForever(shakeAction))
        
        SoundManager.shared.playSound(.mothershipEnraged)
    }
    
    private func updateBehavior(target: PlayerShipNode, deltaTime: TimeInterval) {
        let currentTime = CACurrentMediaTime()
        
        if activeModules > 0 {
            if currentTime - lastFireTime >= GameConfig.Mothership.turretFireRate {
                fireTurrets(at: target)
                lastFireTime = currentTime
            }
        }
        
        if isEnraged {
            if currentTime - lastMissileTime >= 2.0 {
                fireMissiles(at: target)
                lastMissileTime = currentTime
            }
            
            if currentTime - lastBeamTime >= 5.0 && !beamCharging {
                chargeBeam(target: target)
                lastBeamTime = currentTime
            }
        }
    }
    
    private func fireTurrets(at target: PlayerShipNode) {
        for module in modules where !module.isDestroyed {
            let laser = LaserNode(isPlayerLaser: false)
            laser.position = CGPoint(
                x: position.x + module.position.x,
                y: position.y + module.position.y
            )
            laser.damage = GameConfig.Enemy.baseDamage * 1.5
            
            parent?.addChild(laser)
            laser.fireTowards(target: target.position)
            
            createMuzzleFlash(at: module.position)
        }
        
        SoundManager.shared.playSound(.mothershipFire)
    }
    
    private func fireMissiles(at target: PlayerShipNode) {
        for i in 0..<3 {
            let missile = createMissile()
            missile.position = CGPoint(
                x: position.x + CGFloat(i - 1) * 30,
                y: position.y
            )
            
            parent?.addChild(missile)
            guideMissile(missile, to: target)
        }
        
        SoundManager.shared.playSound(.mothershipMissile)
    }
    
    private func createMissile() -> SKSpriteNode {
        let missile = SKSpriteNode(texture: nil, color: .yellow, size: CGSize(width: 8, height: 20))
        missile.colorBlendFactor = 1.0
        
        missile.physicsBody = PhysicsHelper.createRectangleBody(size: missile.size)
        PhysicsHelper.configureBody(
            for: missile.physicsBody!,
            category: PhysicsCategory.laserEnemy,
            contact: PhysicsCategory.player | PhysicsCategory.shield,
            collision: PhysicsCategory.none
        )
        
        let trail = SKEmitterNode()
        trail.particleTexture = SKTexture(imageNamed: "spark")
        trail.particleBirthRate = 30
        trail.particleLifetime = 0.5
        trail.particleLifetimeRange = 0.2
        trail.emissionAngle = CGFloat.pi
        trail.emissionAngleRange = CGFloat.pi / 6
        trail.particleSpeed = 60
        trail.particleSpeedRange = 30
        trail.particleScale = 0.4
        trail.particleScaleRange = 0.2
        trail.particleAlpha = 0.8
        trail.particleAlphaSpeed = -1.5
        trail.particleColorRed = 1.0
        trail.particleColorGreen = 0.8
        trail.particleColorBlue = 0.0
        
        missile.addChild(trail)
        
        return missile
    }
    
    private func guideMissile(_ missile: SKSpriteNode, to target: PlayerShipNode) {
        let homingAction = SKAction.run {
            let direction = CGVector(
                dx: target.position.x - missile.position.x,
                dy: target.position.y - missile.position.y
            )
            let distance = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
            if distance > 0 {
                let normalizedDirection = CGVector(
                    dx: direction.dx / distance,
                    dy: direction.dy / distance
                )
                
                missile.physicsBody?.velocity = CGVector(
                    dx: normalizedDirection.dx * 300,
                    dy: normalizedDirection.dy * 300
                )
                
                let angle = atan2(normalizedDirection.dy, normalizedDirection.dx) - CGFloat.pi / 2
                missile.zRotation = angle
            }
        }
        
        let repeatHoming = SKAction.repeatForever(SKAction.sequence([
            homingAction,
            SKAction.wait(forDuration: 0.1)
        ]))
        
        let cleanup = SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.removeFromParent()
        ])
        
        missile.run(SKAction.group([repeatHoming, cleanup]))
    }
    
    private func chargeBeam(target: PlayerShipNode) {
        beamCharging = true
        
        let chargeNode = SKShapeNode(circleOfRadius: 20)
        chargeNode.fillColor = .red
        chargeNode.strokeColor = .white
        chargeNode.lineWidth = 3
        chargeNode.position = CGPoint.zero
        chargeNode.alpha = 0.8
        coreNode?.addChild(chargeNode)
        
        let chargeEffect = SKAction.sequence([
            SKAction.scale(to: 2.0, duration: 2.0),
            SKAction.run { [weak self] in
                self?.fireBeam(at: target, chargeNode: chargeNode)
            }
        ])
        
        chargeNode.run(chargeEffect)
        
        SoundManager.shared.playSound(.mothershipBeamCharge)
    }
    
    private func fireBeam(at target: PlayerShipNode, chargeNode: SKShapeNode) {
        let beam = createBeam(to: target.position)
        parent?.addChild(beam)
        
        chargeNode.removeFromParent()
        beamCharging = false
        
        SoundManager.shared.playSound(.mothershipBeamFire)
        HapticManager.shared.playExplosion()
        
        if distance(from: position, to: target.position) <= 500 {
            target.takeDamage(GameConfig.Mothership.beamDamage)
        }
    }
    
    private func createBeam(to targetPosition: CGPoint) -> SKSpriteNode {
        let distance = distance(from: position, to: targetPosition)
        let beam = SKSpriteNode(texture: nil, color: .red, size: CGSize(width: 10, height: distance))
        beam.colorBlendFactor = 1.0
        beam.alpha = 0.9
        
        let midPoint = CGPoint(
            x: (position.x + targetPosition.x) / 2,
            y: (position.y + targetPosition.y) / 2
        )
        beam.position = midPoint
        
        let angle = atan2(targetPosition.y - position.y, targetPosition.x - position.x) - CGFloat.pi / 2
        beam.zRotation = angle
        
        let beamGlow = SKSpriteNode(texture: nil, color: .red, size: CGSize(width: 20, height: distance))
        beamGlow.alpha = 0.5
        beamGlow.blendMode = .add
        beam.addChild(beamGlow)
        
        let fadeOut = SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ])
        beam.run(fadeOut)
        
        return beam
    }
    
    private func createMuzzleFlash(at position: CGPoint) {
        let flash = SKEmitterNode()
        flash.particleTexture = SKTexture(imageNamed: "spark")
        flash.particleBirthRate = 100
        flash.numParticlesToEmit = 15
        flash.particleLifetime = 0.3
        flash.particleLifetimeRange = 0.1
        flash.emissionAngleRange = CGFloat.pi / 4
        flash.particleSpeed = 80
        flash.particleSpeedRange = 40
        flash.particleScale = 0.4
        flash.particleScaleRange = 0.2
        flash.particleAlpha = 1.0
        flash.particleAlphaSpeed = -3.0
        flash.particleColorRed = 1.0
        flash.particleColorGreen = 0.5
        flash.particleColorBlue = 0.0
        flash.position = position
        
        addChild(flash)
        
        let removeFlash = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.removeFromParent()
        ])
        flash.run(removeFlash)
    }
    
    private func updateVisuals() {
        let healthPercentage = health / maxHealth
        
        if healthPercentage < 0.3 {
            let sparks = createDamageSparks()
            addChild(sparks)
        }
    }
    
    private func createDamageSparks() -> SKEmitterNode {
        let sparks = SKEmitterNode()
        sparks.particleTexture = SKTexture(imageNamed: "spark")
        sparks.particleBirthRate = 15
        sparks.particleLifetime = 1.0
        sparks.particleLifetimeRange = 0.5
        sparks.emissionAngleRange = CGFloat.pi * 2
        sparks.particleSpeed = 50
        sparks.particleSpeedRange = 25
        sparks.particleScale = 0.3
        sparks.particleScaleRange = 0.2
        sparks.particleAlpha = 0.8
        sparks.particleAlphaSpeed = -0.8
        sparks.particleColorRed = 1.0
        sparks.particleColorGreen = 0.7
        sparks.particleColorBlue = 0.0
        sparks.position = CGPoint(x: CGFloat.random(in: -100...100), y: CGFloat.random(in: -50...50))
        
        let removeSparks = SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ])
        sparks.run(removeSparks)
        
        return sparks
    }
    
    func takeDamage(_ damage: CGFloat) -> Bool {
        health -= damage
        health = max(0, health)
        
        createDamageEffect()
        
        if health <= 0 {
            destroy()
            return true
        }
        
        return false
    }
    
    func moduleDestroyed() {
        let remaining = activeModules
        if remaining <= 0 && health > 0 {
            takeDamage(health * 0.2)
        }
    }
    
    private func createDamageEffect() {
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.colorize(with: isEnraged ? .red : .purple, colorBlendFactor: 0.2, duration: 0.1)
        ])
        run(flash)
        
        HapticManager.shared.playImpact(intensity: .hapticIntensity, sharpness: 0.8)
    }
    
    private func destroy() {
        SoundManager.shared.playSound(.mothershipDestroyed)
        HapticManager.shared.playExplosion()
        
        for i in 0..<5 {
            let explosion = createFinalExplosion(delay: Double(i) * 0.3)
            parent?.addChild(explosion)
        }
        
        let finalAction = SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ])
        run(finalAction)
    }
    
    private func createFinalExplosion(delay: TimeInterval) -> SKEmitterNode {
        let explosion = SKEmitterNode()
        explosion.particleTexture = SKTexture(imageNamed: "spark")
        explosion.particleBirthRate = 200
        explosion.numParticlesToEmit = 100
        explosion.particleLifetime = 3.0
        explosion.particleLifetimeRange = 1.5
        explosion.emissionAngleRange = CGFloat.pi * 2
        explosion.particleSpeed = 300
        explosion.particleSpeedRange = 150
        explosion.particleScale = 1.5
        explosion.particleScaleRange = 0.8
        explosion.particleColorRed = 1.0
        explosion.particleColorGreen = 0.3
        explosion.particleColorBlue = 0.0
        explosion.particleAlpha = 1.0
        explosion.particleAlphaSpeed = -0.3
        
        explosion.position = CGPoint(
            x: position.x + CGFloat.random(in: -100...100),
            y: position.y + CGFloat.random(in: -80...80)
        )
        
        let startExplosion = SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.run {
                explosion.resetSimulation()
            }
        ])
        
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: delay + 4.0),
            SKAction.removeFromParent()
        ])
        
        explosion.run(SKAction.group([startExplosion, removeAction]))
        
        return explosion
    }
    
    private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        let dx = to.x - from.x
        let dy = to.y - from.y
        return sqrt(dx * dx + dy * dy)
    }
}