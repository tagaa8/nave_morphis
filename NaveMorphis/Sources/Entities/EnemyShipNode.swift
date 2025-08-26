import SpriteKit
import GameplayKit

enum EnemyType {
    case hunter, sniper
}

class EnemyShipNode: SKSpriteNode {
    
    var enemyType: EnemyType = .hunter
    var health: CGFloat = GameConfig.Enemy.baseHealth
    var maxHealth: CGFloat = GameConfig.Enemy.baseHealth
    var speed: CGFloat = GameConfig.Enemy.baseSpeed
    var damage: CGFloat = GameConfig.Enemy.baseDamage
    var fireRate: TimeInterval = GameConfig.Enemy.baseFireRate
    var lastFireTime: TimeInterval = 0
    var scoreValue: Int = GameConfig.Enemy.scoreValue
    
    private var target: PlayerShipNode?
    private var velocity: CGVector = CGVector.zero
    private var steeringForce: CGVector = CGVector.zero
    private var healthBar: SKShapeNode?
    private var alertRadius: SKShapeNode?
    
    private let maxForce: CGFloat = 300
    private let maxSpeed: CGFloat = 250
    private let separationRadius: CGFloat = 100
    private let cohesionRadius: CGFloat = 150
    private let alignmentRadius: CGFloat = 120
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        setupEnemy()
    }
    
    convenience init(type: EnemyType) {
        let texture = SKTexture(imageNamed: "enemy_ship")
        self.init(texture: texture, color: .clear, size: CGSize(width: 50, height: 50))
        self.enemyType = type
        configureForType()
        setupPhysics()
        setupVisuals()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupEnemy() {
        colorBlendFactor = 0.3
    }
    
    private func configureForType() {
        switch enemyType {
        case .hunter:
            color = .red
            speed = GameConfig.Enemy.baseSpeed * 1.2
            health = GameConfig.Enemy.baseHealth * 0.8
            fireRate = GameConfig.Enemy.baseFireRate * 1.5
            scoreValue = Int(CGFloat(GameConfig.Enemy.scoreValue) * 1.2)
            
        case .sniper:
            color = .orange
            speed = GameConfig.Enemy.baseSpeed * 0.7
            health = GameConfig.Enemy.baseHealth * 1.5
            fireRate = GameConfig.Enemy.baseFireRate * 0.8
            damage = GameConfig.Enemy.baseDamage * 1.3
            scoreValue = Int(CGFloat(GameConfig.Enemy.scoreValue) * 1.5)
        }
        
        maxHealth = health
    }
    
    private func setupPhysics() {
        physicsBody = PhysicsHelper.createCircleBody(radius: size.width / 2)
        PhysicsHelper.configureBody(
            for: physicsBody!,
            category: PhysicsCategory.enemy,
            contact: PhysicsCategory.player | PhysicsCategory.laserPlayer,
            collision: PhysicsCategory.boundary
        )
        physicsBody?.mass = 0.8
        physicsBody?.linearDamping = 1.5
    }
    
    private func setupVisuals() {
        setupHealthBar()
        setupAlertRadius()
        
        let engineGlow = SKSpriteNode(texture: nil, color: color, size: CGSize(width: size.width * 0.3, height: size.height * 0.6))
        engineGlow.position = CGPoint(x: 0, y: -size.height / 2)
        engineGlow.alpha = 0.6
        engineGlow.blendMode = .add
        addChild(engineGlow)
        
        let pulseAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.5),
            SKAction.fadeAlpha(to: 0.8, duration: 0.5)
        ])
        engineGlow.run(SKAction.repeatForever(pulseAction))
    }
    
    private func setupHealthBar() {
        let barWidth: CGFloat = size.width
        let barHeight: CGFloat = 3
        
        let background = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        background.fillColor = .darkGray
        background.strokeColor = .clear
        background.position = CGPoint(x: 0, y: size.height / 2 + 10)
        background.alpha = 0.8
        addChild(background)
        
        healthBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        healthBar?.fillColor = .red
        healthBar?.strokeColor = .clear
        healthBar?.position = CGPoint(x: 0, y: size.height / 2 + 10)
        healthBar?.alpha = 0.8
        
        if let healthBar = healthBar {
            addChild(healthBar)
        }
    }
    
    private func setupAlertRadius() {
        alertRadius = SKShapeNode(circleOfRadius: GameConfig.Enemy.sniperRange)
        alertRadius?.strokeColor = .yellow
        alertRadius?.lineWidth = 1
        alertRadius?.fillColor = .clear
        alertRadius?.alpha = 0
        
        if enemyType == .sniper, let alertRadius = alertRadius {
            addChild(alertRadius)
        }
    }
    
    func setTarget(_ target: PlayerShipNode) {
        self.target = target
    }
    
    func update(deltaTime: TimeInterval, enemies: [EnemyShipNode]) {
        guard let target = target else { return }
        
        updateAI(target: target, deltaTime: deltaTime, enemies: enemies)
        updateHealthBar()
        updateVisuals()
        attemptToFire()
    }
    
    private func updateAI(target: PlayerShipNode, deltaTime: TimeInterval, enemies: [EnemyShipNode]) {
        let distanceToTarget = distance(from: position, to: target.position)
        
        switch enemyType {
        case .hunter:
            updateHunterBehavior(target: target, deltaTime: deltaTime, enemies: enemies)
        case .sniper:
            updateSniperBehavior(target: target, deltaTime: deltaTime, distanceToTarget: distanceToTarget)
        }
        
        applyMovement(deltaTime: deltaTime)
    }
    
    private func updateHunterBehavior(target: PlayerShipNode, deltaTime: TimeInterval, enemies: [EnemyShipNode]) {
        var steering = CGVector.zero
        
        let seekForce = seek(target: target.position)
        let separationForce = separate(from: enemies)
        let avoidanceForce = avoidBoundaries()
        
        steering.dx += seekForce.dx * 0.6 + separationForce.dx * 0.3 + avoidanceForce.dx * 0.8
        steering.dy += seekForce.dy * 0.6 + separationForce.dy * 0.3 + avoidanceForce.dy * 0.8
        
        steeringForce = limitForce(steering, maxForce: maxForce)
        
        velocity.dx += steeringForce.dx * CGFloat(deltaTime)
        velocity.dy += steeringForce.dy * CGFloat(deltaTime)
        velocity = limitForce(velocity, maxForce: maxSpeed)
        
        if velocity.dx != 0 || velocity.dy != 0 {
            let angle = atan2(velocity.dy, velocity.dx) - CGFloat.pi / 2
            zRotation = angle
        }
    }
    
    private func updateSniperBehavior(target: PlayerShipNode, deltaTime: TimeInterval, distanceToTarget: CGFloat) {
        let optimalRange = GameConfig.Enemy.sniperRange * 0.8
        var steering = CGVector.zero
        
        if distanceToTarget < optimalRange {
            steering = flee(from: target.position)
            alertRadius?.alpha = 0.3
        } else if distanceToTarget > GameConfig.Enemy.sniperRange {
            steering = seek(target: target.position)
            alertRadius?.alpha = 0
        } else {
            steering = orbit(around: target.position, radius: optimalRange)
            alertRadius?.alpha = 0.5
        }
        
        let avoidanceForce = avoidBoundaries()
        steering.dx += avoidanceForce.dx * 0.8
        steering.dy += avoidanceForce.dy * 0.8
        
        steeringForce = limitForce(steering, maxForce: maxForce * 0.7)
        
        velocity.dx += steeringForce.dx * CGFloat(deltaTime)
        velocity.dy += steeringForce.dy * CGFloat(deltaTime)
        velocity = limitForce(velocity, maxForce: maxSpeed * 0.8)
        
        let angleToTarget = atan2(target.position.y - position.y, target.position.x - position.x) - CGFloat.pi / 2
        zRotation = angleToTarget
    }
    
    private func seek(target: CGPoint) -> CGVector {
        let desired = CGVector(
            dx: target.x - position.x,
            dy: target.y - position.y
        )
        let normalizedDesired = normalize(desired)
        return CGVector(
            dx: normalizedDesired.dx * maxSpeed - velocity.dx,
            dy: normalizedDesired.dy * maxSpeed - velocity.dy
        )
    }
    
    private func flee(from: CGPoint) -> CGVector {
        let desired = CGVector(
            dx: position.x - from.x,
            dy: position.y - from.y
        )
        let normalizedDesired = normalize(desired)
        return CGVector(
            dx: normalizedDesired.dx * maxSpeed - velocity.dx,
            dy: normalizedDesired.dy * maxSpeed - velocity.dy
        )
    }
    
    private func orbit(around center: CGPoint, radius: CGFloat) -> CGVector {
        let toCenter = CGVector(dx: center.x - position.x, dy: center.y - position.y)
        let distance = sqrt(toCenter.dx * toCenter.dx + toCenter.dy * toCenter.dy)
        
        if distance == 0 { return CGVector.zero }
        
        let tangent = CGVector(dx: -toCenter.dy, dy: toCenter.dx)
        let normalizedTangent = normalize(tangent)
        
        return CGVector(
            dx: normalizedTangent.dx * maxSpeed * 0.5 - velocity.dx,
            dy: normalizedTangent.dy * maxSpeed * 0.5 - velocity.dy
        )
    }
    
    private func separate(from enemies: [EnemyShipNode]) -> CGVector {
        var separation = CGVector.zero
        var count = 0
        
        for enemy in enemies {
            if enemy != self {
                let d = distance(from: position, to: enemy.position)
                if d > 0 && d < separationRadius {
                    let diff = CGVector(
                        dx: position.x - enemy.position.x,
                        dy: position.y - enemy.position.y
                    )
                    let normalizedDiff = normalize(diff)
                    separation.dx += normalizedDiff.dx / d
                    separation.dy += normalizedDiff.dy / d
                    count += 1
                }
            }
        }
        
        if count > 0 {
            separation.dx /= CGFloat(count)
            separation.dy /= CGFloat(count)
            let normalizedSeparation = normalize(separation)
            return CGVector(
                dx: normalizedSeparation.dx * maxSpeed - velocity.dx,
                dy: normalizedSeparation.dy * maxSpeed - velocity.dy
            )
        }
        
        return CGVector.zero
    }
    
    private func avoidBoundaries() -> CGVector {
        guard let scene = scene else { return CGVector.zero }
        
        let buffer: CGFloat = 100
        let boundary = scene.frame
        var avoidance = CGVector.zero
        
        if position.x < boundary.minX + buffer {
            avoidance.dx += maxSpeed
        }
        if position.x > boundary.maxX - buffer {
            avoidance.dx -= maxSpeed
        }
        if position.y < boundary.minY + buffer {
            avoidance.dy += maxSpeed
        }
        if position.y > boundary.maxY - buffer {
            avoidance.dy -= maxSpeed
        }
        
        return avoidance
    }
    
    private func applyMovement(deltaTime: TimeInterval) {
        position.x += velocity.dx * CGFloat(deltaTime)
        position.y += velocity.dy * CGFloat(deltaTime)
    }
    
    private func attemptToFire() {
        guard let target = target else { return }
        
        let currentTime = CACurrentMediaTime()
        let distanceToTarget = distance(from: position, to: target.position)
        
        var shouldFire = false
        var fireRange: CGFloat = 300
        
        switch enemyType {
        case .hunter:
            fireRange = 200
            shouldFire = distanceToTarget <= fireRange
        case .sniper:
            fireRange = GameConfig.Enemy.sniperRange
            shouldFire = distanceToTarget <= fireRange && distanceToTarget >= fireRange * 0.5
        }
        
        if shouldFire && currentTime - lastFireTime >= fireRate {
            fire(at: target.position)
            lastFireTime = currentTime
        }
    }
    
    private func fire(at target: CGPoint) {
        let laser = LaserNode(isPlayerLaser: false)
        laser.position = CGPoint(x: position.x, y: position.y + size.height / 2)
        laser.damage = damage
        
        parent?.addChild(laser)
        laser.fireTowards(target: target)
        
        SoundManager.shared.playSound(.enemyFire)
        
        createMuzzleFlash()
    }
    
    private func createMuzzleFlash() {
        let flash = SKEmitterNode()
        flash.particleTexture = SKTexture(imageNamed: "spark")
        flash.particleBirthRate = 50
        flash.numParticlesToEmit = 10
        flash.particleLifetime = 0.2
        flash.particleLifetimeRange = 0.1
        flash.emissionAngleRange = CGFloat.pi / 3
        flash.particleSpeed = 50
        flash.particleSpeedRange = 25
        flash.particleScale = 0.3
        flash.particleScaleRange = 0.2
        flash.particleAlpha = 1.0
        flash.particleAlphaSpeed = -5.0
        flash.particleColorRed = 1.0
        flash.particleColorGreen = 0.3
        flash.particleColorBlue = 0.0
        flash.position = CGPoint(x: 0, y: size.height / 2)
        
        addChild(flash)
        
        let removeFlash = SKAction.sequence([
            SKAction.wait(forDuration: 0.4),
            SKAction.removeFromParent()
        ])
        flash.run(removeFlash)
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
    
    private func createDamageEffect() {
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.colorize(with: color, colorBlendFactor: 0.3, duration: 0.1)
        ])
        run(flash)
        
        let hit = SKEmitterNode()
        hit.particleTexture = SKTexture(imageNamed: "spark")
        hit.particleBirthRate = 30
        hit.numParticlesToEmit = 8
        hit.particleLifetime = 0.3
        hit.particleLifetimeRange = 0.1
        hit.emissionAngleRange = CGFloat.pi * 2
        hit.particleSpeed = 80
        hit.particleSpeedRange = 40
        hit.particleScale = 0.4
        hit.particleScaleRange = 0.2
        hit.particleAlpha = 1.0
        hit.particleAlphaSpeed = -3.0
        hit.particleColorRed = 1.0
        hit.particleColorGreen = 1.0
        hit.particleColorBlue = 0.0
        
        addChild(hit)
        
        let removeHit = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.removeFromParent()
        ])
        hit.run(removeHit)
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
    
    private func updateVisuals() {
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        let speedRatio = speed / maxSpeed
        alpha = 0.8 + speedRatio * 0.2
    }
    
    private func destroy() {
        SoundManager.shared.playSound(.enemyExplosion)
        
        let explosion = createExplosionEffect()
        parent?.addChild(explosion)
        
        spawnPowerUp()
        
        removeFromParent()
    }
    
    private func createExplosionEffect() -> SKEmitterNode {
        let explosion = SKEmitterNode()
        explosion.particleTexture = SKTexture(imageNamed: "spark")
        explosion.particleBirthRate = 100
        explosion.numParticlesToEmit = 30
        explosion.particleLifetime = 1.5
        explosion.particleLifetimeRange = 0.5
        explosion.emissionAngleRange = CGFloat.pi * 2
        explosion.particleSpeed = 150
        explosion.particleSpeedRange = 75
        explosion.particleScale = 0.8
        explosion.particleScaleRange = 0.4
        explosion.particleColorRed = 1.0
        explosion.particleColorGreen = 0.5
        explosion.particleColorBlue = 0.0
        explosion.particleAlpha = 1.0
        explosion.particleAlphaSpeed = -0.7
        explosion.position = position
        
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ])
        explosion.run(removeAction)
        
        return explosion
    }
    
    private func spawnPowerUp() {
        if Float.random(in: 0...1) < GameConfig.PowerUp.spawnChance {
            let powerUp = PowerUpNode()
            powerUp.position = position
            parent?.addChild(powerUp)
        }
    }
    
    private func normalize(_ vector: CGVector) -> CGVector {
        let length = sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
        if length == 0 {
            return CGVector.zero
        }
        return CGVector(dx: vector.dx / length, dy: vector.dy / length)
    }
    
    private func limitForce(_ force: CGVector, maxForce: CGFloat) -> CGVector {
        let magnitude = sqrt(force.dx * force.dx + force.dy * force.dy)
        if magnitude > maxForce {
            return CGVector(
                dx: (force.dx / magnitude) * maxForce,
                dy: (force.dy / magnitude) * maxForce
            )
        }
        return force
    }
    
    private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        let dx = to.x - from.x
        let dy = to.y - from.y
        return sqrt(dx * dx + dy * dy)
    }
}