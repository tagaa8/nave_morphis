import SpriteKit
import GameplayKit

class PlayerShip3D: SKSpriteNode {
    
    // MARK: - Properties
    var velocity = CGVector.zero
    var maxSpeed: CGFloat = 300
    var acceleration: CGFloat = 800
    var friction: CGFloat = 0.95
    
    // Power-up states
    private var rapidFireActive = false
    private var shieldActive = false
    private var tripleShotActive = false
    private var rapidFireTimer: Timer?
    private var shieldTimer: Timer?
    private var tripleShotTimer: Timer?
    
    // Visual effects
    private var thrusterParticles: SKEmitterNode!
    private var shieldEffect: SKShapeNode?
    private var glowEffect: SKEffectNode!
    
    // Animation and scaling
    private var baseScale: CGFloat = 1.0
    private var tiltAngle: CGFloat = 0
    
    init() {
        let texture = SKTexture(imageNamed: "player_ship")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        setupPhysics()
        setupVisualEffects()
        setupAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.categoryBitMask = 0x1 << 0 // playerCategory
        physicsBody?.contactTestBitMask = 0x1 << 1 | 0x1 << 3 // enemy and powerUp
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.linearDamping = 0.1
    }
    
    private func setupVisualEffects() {
        // Glow effect for the ship
        glowEffect = SKEffectNode()
        glowEffect.shouldRasterize = true
        glowEffect.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10])
        
        let glowSprite = SKSpriteNode(texture: texture)
        glowSprite.color = .cyan
        glowSprite.colorBlendFactor = 1.0
        glowSprite.alpha = 0.6
        glowEffect.addChild(glowSprite)
        glowEffect.zPosition = -1
        addChild(glowEffect)
        
        // Thruster particles
        thrusterParticles = createThrusterEffect()
        thrusterParticles.position = CGPoint(x: 0, y: -size.height/2)
        thrusterParticles.zPosition = -2
        addChild(thrusterParticles)
        
        // Base scale for breathing effect
        baseScale = 1.0
        setScale(baseScale)
    }
    
    private func createThrusterEffect() -> SKEmitterNode {
        let particles = SKEmitterNode()
        
        // Particle properties
        particles.particleTexture = SKTexture(imageNamed: "spark")
        particles.particleLifetime = 0.5
        particles.particleBirthRate = 100
        particles.particlePositionRange = CGVector(dx: 10, dy: 5)
        particles.emissionAngleRange = CGFloat.pi / 6
        
        // Movement
        particles.particleSpeed = 100
        particles.particleSpeedRange = 50
        particles.emissionAngle = CGFloat.pi * 1.5 // Downward
        
        // Visual
        particles.particleScale = 0.3
        particles.particleScaleRange = 0.2
        particles.particleScaleSpeed = -0.5
        
        // Color animation - cyan to white to transparent
        particles.particleColorSequence = createThrusterColorSequence()
        
        // Alpha
        particles.particleAlpha = 0.8
        particles.particleAlphaSpeed = -1.6
        
        return particles
    }
    
    private func createThrusterColorSequence() -> SKKeyframeSequence? {
        let colors = [
            SKColor.cyan,
            SKColor.white,
            SKColor.cyan.withAlphaComponent(0.5),
            SKColor.clear
        ]
        
        let times = [0.0, 0.3, 0.7, 1.0] as [NSNumber]
        return SKKeyframeSequence(keyframeValues: colors, times: times)
    }
    
    private func setupAnimations() {
        // Breathing/pulsing effect
        let breathe = SKAction.sequence([
            SKAction.scale(to: baseScale * 1.05, duration: 1.0),
            SKAction.scale(to: baseScale * 0.95, duration: 1.0)
        ])
        run(SKAction.repeatForever(breathe))
        
        // Glow pulsing
        let glowPulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.8),
            SKAction.fadeAlpha(to: 0.8, duration: 0.8)
        ])
        glowEffect.run(SKAction.repeatForever(glowPulse))
    }
    
    // MARK: - Update Methods
    
    func update(_ currentTime: TimeInterval, leftStick: CGPoint) {
        updateMovement(leftStick)
        updateVisuals()
        constrainToScreen()
    }
    
    private func updateMovement(_ leftStick: CGPoint) {
        // Apply thumbstick input
        if leftStick != CGPoint.zero {
            velocity.dx += leftStick.x * acceleration * (1.0/60.0) // Assuming 60 FPS
            velocity.dy += leftStick.y * acceleration * (1.0/60.0)
            
            // Update thruster intensity based on movement
            thrusterParticles.particleBirthRate = 150
            
            // Tilt ship based on movement direction
            tiltAngle = atan2(leftStick.x, leftStick.y) * 0.3
        } else {
            thrusterParticles.particleBirthRate = 50
            tiltAngle *= 0.9 // Return to upright
        }
        
        // Apply velocity limits
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        if speed > maxSpeed {
            velocity.dx = (velocity.dx / speed) * maxSpeed
            velocity.dy = (velocity.dy / speed) * maxSpeed
        }
        
        // Apply friction
        velocity.dx *= friction
        velocity.dy *= friction
        
        // Apply velocity to position
        position.x += velocity.dx * (1.0/60.0)
        position.y += velocity.dy * (1.0/60.0)
    }
    
    private func updateVisuals() {
        // Apply tilt rotation
        zRotation = tiltAngle
        
        // Update thruster direction based on movement
        if velocity.dx != 0 || velocity.dy != 0 {
            let angle = atan2(-velocity.dx, -velocity.dy)
            thrusterParticles.emissionAngle = angle
            thrusterParticles.emissionAngleRange = CGFloat.pi / 8
        } else {
            thrusterParticles.emissionAngle = CGFloat.pi * 1.5
            thrusterParticles.emissionAngleRange = CGFloat.pi / 6
        }
    }
    
    private func constrainToScreen() {
        guard let scene = scene else { return }
        
        let margin: CGFloat = size.width / 2
        position.x = max(margin, min(scene.frame.maxX - margin, position.x))
        position.y = max(margin, min(scene.frame.maxY - margin, position.y))
    }
    
    // MARK: - Power-up System
    
    func activateRapidFire() {
        rapidFireActive = true
        
        // Visual indication
        let rapidFireGlow = SKAction.sequence([
            SKAction.colorize(with: .yellow, colorBlendFactor: 0.3, duration: 0.2),
            SKAction.colorize(with: .cyan, colorBlendFactor: 0.0, duration: 0.2)
        ])
        run(SKAction.repeat(rapidFireGlow, count: 15))
        
        rapidFireTimer?.invalidate()
        rapidFireTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { [weak self] _ in
            self?.rapidFireActive = false
        }
    }
    
    func activateShield() {
        shieldActive = true
        
        // Create shield visual
        createShieldEffect()
        
        shieldTimer?.invalidate()
        shieldTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.deactivateShield()
        }
    }
    
    func activateTripleShot() {
        tripleShotActive = true
        
        // Visual indication
        let tripleShotGlow = SKAction.sequence([
            SKAction.colorize(with: .magenta, colorBlendFactor: 0.3, duration: 0.3),
            SKAction.colorize(with: .cyan, colorBlendFactor: 0.0, duration: 0.3)
        ])
        run(SKAction.repeat(tripleShotGlow, count: 10))
        
        tripleShotTimer?.invalidate()
        tripleShotTimer = Timer.scheduledTimer(withTimeInterval: 12.0, repeats: false) { [weak self] _ in
            self?.tripleShotActive = false
        }
    }
    
    private func createShieldEffect() {
        shieldEffect?.removeFromParent()
        
        let shieldRadius = size.width * 0.8
        shieldEffect = SKShapeNode(circleOfRadius: shieldRadius)
        shieldEffect!.strokeColor = .cyan
        shieldEffect!.lineWidth = 3
        shieldEffect!.fillColor = .cyan.withAlphaComponent(0.1)
        shieldEffect!.alpha = 0.7
        shieldEffect!.zPosition = 1
        
        addChild(shieldEffect!)
        
        // Shield animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 0.9, duration: 0.5)
        ])
        shieldEffect!.run(SKAction.repeatForever(pulse))
        
        // Shimmer effect
        let shimmer = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.8),
            SKAction.fadeAlpha(to: 0.9, duration: 0.8)
        ])
        shieldEffect!.run(SKAction.repeatForever(shimmer))
    }
    
    private func deactivateShield() {
        shieldActive = false
        
        // Shield break animation
        shieldEffect?.run(SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.3),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
    
    // MARK: - Combat Methods
    
    func canFire() -> Bool {
        return rapidFireActive // Could add cooldown logic here
    }
    
    func getShotCount() -> Int {
        return tripleShotActive ? 3 : 1
    }
    
    func isShielded() -> Bool {
        return shieldActive
    }
    
    // MARK: - Damage and Effects
    
    func takeDamage() {
        if shieldActive {
            // Shield absorbs damage
            deactivateShield()
            
            // Shield break effect
            let shieldBreak = SKEmitterNode()
            shieldBreak.particleTexture = SKTexture(imageNamed: "spark")
            shieldBreak.particleLifetime = 0.8
            shieldBreak.particleBirthRate = 200
            shieldBreak.numParticlesToEmit = 50
            shieldBreak.particlePositionRange = CGVector(dx: size.width, dy: size.height)
            shieldBreak.particleSpeed = 150
            shieldBreak.particleSpeedRange = 100
            shieldBreak.particleColor = .cyan
            shieldBreak.particleAlpha = 0.8
            shieldBreak.particleAlphaSpeed = -1.0
            shieldBreak.particleScale = 0.5
            shieldBreak.particleScaleSpeed = -0.5
            
            addChild(shieldBreak)
            
            shieldBreak.run(SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.removeFromParent()
            ]))
        } else {
            // Take actual damage
            let damageFlash = SKAction.sequence([
                SKAction.colorize(with: .red, colorBlendFactor: 0.8, duration: 0.1),
                SKAction.colorize(with: .cyan, colorBlendFactor: 0.0, duration: 0.1)
            ])
            run(SKAction.repeat(damageFlash, count: 3))
        }
    }
    
    deinit {
        rapidFireTimer?.invalidate()
        shieldTimer?.invalidate()
        tripleShotTimer?.invalidate()
    }
}