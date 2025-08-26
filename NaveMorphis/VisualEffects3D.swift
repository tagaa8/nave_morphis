import SpriteKit
import GameplayKit

// MARK: - Star Field 3D
class StarField3D: SKNode {
    
    private var starLayers: [StarLayer] = []
    private let layerCount = 5
    private var parallaxStrength: CGFloat = 0.3
    
    init(size: CGSize) {
        super.init()
        
        createStarLayers(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createStarLayers(size: CGSize) {
        for i in 0..<layerCount {
            let depth = CGFloat(i + 1)
            let layer = StarLayer(
                size: size,
                depth: depth,
                starCount: 150 - i * 20, // Fewer stars in distant layers
                maxAlpha: 1.0 - CGFloat(i) * 0.15,
                speed: 1.0 / depth // Slower movement for distant layers
            )
            layer.zPosition = -100 - CGFloat(i * 10)
            addChild(layer)
            starLayers.append(layer)
        }
    }
    
    func update(_ currentTime: TimeInterval, playerVelocity: CGVector) {
        for (index, layer) in starLayers.enumerated() {
            let depth = CGFloat(index + 1)
            let parallaxOffset = CGVector(
                dx: -playerVelocity.dx * parallaxStrength / depth,
                dy: -playerVelocity.dy * parallaxStrength / depth
            )
            layer.update(currentTime, parallaxOffset: parallaxOffset)
        }
    }
}

class StarLayer: SKNode {
    private var stars: [Star3D] = []
    private let layerSize: CGSize
    private let depth: CGFloat
    private let baseSpeed: CGFloat
    
    init(size: CGSize, depth: CGFloat, starCount: Int, maxAlpha: CGFloat, speed: CGFloat) {
        self.layerSize = size
        self.depth = depth
        self.baseSpeed = speed
        
        super.init()
        
        createStars(count: starCount, maxAlpha: maxAlpha)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createStars(count: Int, maxAlpha: CGFloat) {
        for _ in 0..<count {
            let star = Star3D(
                maxAlpha: maxAlpha,
                depth: depth,
                screenSize: layerSize
            )
            stars.append(star)
            addChild(star)
        }
    }
    
    func update(_ currentTime: TimeInterval, parallaxOffset: CGVector) {
        for star in stars {
            star.update(currentTime, parallaxOffset: parallaxOffset, screenSize: layerSize)
        }
    }
}

class Star3D: SKSpriteNode {
    private let maxAlpha: CGFloat
    private let depth: CGFloat
    private var twinklePhase: CGFloat
    private var driftVelocity: CGVector
    
    init(maxAlpha: CGFloat, depth: CGFloat, screenSize: CGSize) {
        self.maxAlpha = maxAlpha
        self.depth = depth
        self.twinklePhase = CGFloat.random(in: 0...(2 * CGFloat.pi))
        self.driftVelocity = CGVector(
            dx: CGFloat.random(in: -10...10) / depth,
            dy: CGFloat.random(in: -10...10) / depth
        )
        
        // Star size based on depth
        let starSize = max(1.0, 4.0 / depth)
        
        super.init(texture: nil, color: .white, size: CGSize(width: starSize, height: starSize))
        
        // Random position
        position = CGPoint(
            x: CGFloat.random(in: 0...screenSize.width),
            y: CGFloat.random(in: 0...screenSize.height)
        )
        
        // Random color tint
        let colors: [UIColor] = [.white, .cyan, .yellow, .blue.withAlphaComponent(0.8)]
        color = colors.randomElement()!
        colorBlendFactor = 0.3
        
        alpha = CGFloat.random(in: maxAlpha * 0.3...maxAlpha)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ currentTime: TimeInterval, parallaxOffset: CGVector, screenSize: CGSize) {
        // Twinkling effect
        twinklePhase += 0.02
        let twinkle = sin(twinklePhase) * 0.3 + 0.7
        alpha = maxAlpha * twinkle
        
        // Parallax movement
        position.x += parallaxOffset.dx + driftVelocity.dx
        position.y += parallaxOffset.dy + driftVelocity.dy
        
        // Wrap around screen
        if position.x < -10 {
            position.x = screenSize.width + 10
            position.y = CGFloat.random(in: 0...screenSize.height)
        } else if position.x > screenSize.width + 10 {
            position.x = -10
            position.y = CGFloat.random(in: 0...screenSize.height)
        }
        
        if position.y < -10 {
            position.y = screenSize.height + 10
            position.x = CGFloat.random(in: 0...screenSize.width)
        } else if position.y > screenSize.height + 10 {
            position.y = -10
            position.x = CGFloat.random(in: 0...screenSize.width)
        }
    }
}

// MARK: - Nebula Effects
class NebulaLayer: SKSpriteNode {
    private let depth: CGFloat
    private var driftSpeed: CGFloat
    private var rotationSpeed: CGFloat
    
    init(size: CGSize, depth: CGFloat, color: UIColor, alpha: CGFloat) {
        self.depth = depth
        self.driftSpeed = 20.0 / depth
        self.rotationSpeed = 0.01 / depth
        
        super.init(texture: nil, color: color, size: CGSize(width: size.width * 1.5, height: size.height * 1.5))
        
        self.alpha = alpha
        self.colorBlendFactor = 1.0
        
        // Create nebula texture programmatically
        createNebulaTexture()
        
        // Position randomly
        position = CGPoint(
            x: CGFloat.random(in: -size.width * 0.3...size.width * 1.3),
            y: CGFloat.random(in: -size.height * 0.3...size.height * 1.3)
        )
        
        // Add glow effect
        let glow = SKEffectNode()
        glow.shouldRasterize = true
        glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 20])
        
        let glowSprite = SKSpriteNode(texture: texture, size: size)
        glowSprite.color = color
        glowSprite.colorBlendFactor = 1.0
        glowSprite.alpha = alpha * 0.5
        glow.addChild(glowSprite)
        glow.zPosition = -1
        addChild(glow)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createNebulaTexture() {
        // Create a simple circular gradient texture
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
        let image = renderer.image { context in
            let bounds = CGRect(origin: .zero, size: CGSize(width: 200, height: 200))
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            
            // Create radial gradient
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [UIColor.clear.cgColor, color.cgColor, UIColor.clear.cgColor]
            let locations: [CGFloat] = [0.0, 0.5, 1.0]
            
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations) {
                context.cgContext.drawRadialGradient(
                    gradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: bounds.width / 2,
                    options: []
                )
            }
        }
        
        texture = SKTexture(image: image)
    }
    
    func update(_ currentTime: TimeInterval, playerPosition: CGPoint) {
        // Slow drift
        position.x += cos(currentTime * 0.1) * driftSpeed * 0.01
        position.y += sin(currentTime * 0.15) * driftSpeed * 0.01
        
        // Slow rotation
        zRotation += rotationSpeed
        
        // Subtle parallax based on player position
        let parallaxX = (playerPosition.x - frame.midX) * 0.02 / depth
        let parallaxY = (playerPosition.y - frame.midY) * 0.02 / depth
        position.x -= parallaxX * 0.01
        position.y -= parallaxY * 0.01
    }
}

// MARK: - Space Debris
class SpaceDebris: SKSpriteNode {
    private var rotationSpeed: CGFloat
    private var driftVelocity: CGVector
    private let screenSize: CGSize
    
    init(size: CGSize) {
        self.screenSize = size
        self.rotationSpeed = CGFloat.random(in: -0.02...0.02)
        self.driftVelocity = CGVector(
            dx: CGFloat.random(in: -30...30),
            dy: CGFloat.random(in: -30...30)
        )
        
        // Create random debris shape
        let debrisSize = CGSize(
            width: CGFloat.random(in: 3...8),
            height: CGFloat.random(in: 3...8)
        )
        
        super.init(texture: nil, color: .gray, size: debrisSize)
        
        // Random position
        position = CGPoint(
            x: CGFloat.random(in: 0...size.width),
            y: CGFloat.random(in: 0...size.height)
        )
        
        // Random properties
        alpha = CGFloat.random(in: 0.2...0.6)
        zRotation = CGFloat.random(in: 0...(2 * CGFloat.pi))
        
        // Add subtle glow
        let glow = SKEffectNode()
        glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 2])
        
        let glowSprite = SKSpriteNode(texture: texture, size: debrisSize)
        glowSprite.color = .white
        glowSprite.colorBlendFactor = 0.3
        glowSprite.alpha = 0.3
        glow.addChild(glowSprite)
        glow.zPosition = -1
        addChild(glow)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ currentTime: TimeInterval) {
        // Rotation
        zRotation += rotationSpeed
        
        // Movement
        position.x += driftVelocity.dx * (1.0/60.0)
        position.y += driftVelocity.dy * (1.0/60.0)
        
        // Wrap around screen
        if position.x < -50 {
            position.x = screenSize.width + 50
            position.y = CGFloat.random(in: 0...screenSize.height)
        } else if position.x > screenSize.width + 50 {
            position.x = -50
            position.y = CGFloat.random(in: 0...screenSize.height)
        }
        
        if position.y < -50 {
            position.y = screenSize.height + 50
            position.x = CGFloat.random(in: 0...screenSize.width)
        } else if position.y > screenSize.height + 50 {
            position.y = -50
            position.x = CGFloat.random(in: 0...screenSize.width)
        }
    }
}

// MARK: - Laser Effects 3D
class Laser3D: SKSpriteNode {
    private var velocity: CGVector
    private var lifetime: TimeInterval = 3.0
    private var creationTime: TimeInterval
    private let laserType: LaserType
    private var trail: SKEmitterNode!
    
    enum LaserType {
        case player, enemy
    }
    
    init(from startPosition: CGPoint, direction: CGPoint, type: LaserType) {
        self.laserType = type
        self.creationTime = CACurrentMediaTime()
        
        let speed: CGFloat = type == .player ? 400 : 300
        self.velocity = CGVector(dx: direction.x * speed, dy: direction.y * speed)
        
        // Different laser appearances
        let laserSize = type == .player ? CGSize(width: 4, height: 12) : CGSize(width: 3, height: 10)
        let laserColor = type == .player ? UIColor.green : UIColor.red
        
        super.init(texture: nil, color: laserColor, size: laserSize)
        
        position = startPosition
        colorBlendFactor = 1.0
        
        // Rotate to face direction
        let angle = atan2(direction.y, direction.x) + CGFloat.pi/2
        zRotation = angle
        
        setupPhysics(type: type)
        createTrailEffect(type: type)
        createGlowEffect(color: laserColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics(type: LaserType) {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = 0x1 << 2 // laserCategory
        
        switch type {
        case .player:
            physicsBody?.contactTestBitMask = 0x1 << 1 | 0x1 << 4 // enemy and mothership
        case .enemy:
            physicsBody?.contactTestBitMask = 0x1 << 0 // player
        }
        
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.velocity = velocity
    }
    
    private func createTrailEffect(type: LaserType) {
        trail = SKEmitterNode()
        trail.particleTexture = SKTexture(imageNamed: "spark")
        trail.particleLifetime = 0.3
        trail.particleBirthRate = 100
        trail.particleSpeed = 50
        trail.particleSpeedRange = 30
        trail.particlePositionRange = CGVector(dx: 2, dy: 2)
        trail.emissionAngle = zRotation + CGFloat.pi
        trail.emissionAngleRange = CGFloat.pi / 6
        
        switch type {
        case .player:
            trail.particleColor = .green
            trail.particleColorBlendFactor = 0.8
        case .enemy:
            trail.particleColor = .red
            trail.particleColorBlendFactor = 0.8
        }
        
        trail.particleAlpha = 0.6
        trail.particleAlphaSpeed = -2.0
        trail.particleScale = 0.2
        trail.particleScaleSpeed = -0.3
        trail.zPosition = -1
        
        addChild(trail)
    }
    
    private func createGlowEffect(color: UIColor) {
        let glow = SKEffectNode()
        glow.shouldRasterize = true
        glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 3])
        
        let glowSprite = SKSpriteNode(texture: texture, size: CGSize(width: size.width * 2, height: size.height * 2))
        glowSprite.color = color
        glowSprite.colorBlendFactor = 1.0
        glowSprite.alpha = 0.5
        glow.addChild(glowSprite)
        glow.zPosition = -2
        addChild(glow)
    }
    
    func update(_ currentTime: TimeInterval) {
        // Check lifetime
        if currentTime - creationTime > lifetime {
            removeFromParent()
        }
        
        // Update trail emission angle to follow laser direction
        if velocity.dx != 0 || velocity.dy != 0 {
            let angle = atan2(velocity.dy, velocity.dx)
            trail.emissionAngle = angle + CGFloat.pi
        }
    }
    
    func getLaserType() -> LaserType {
        return laserType
    }
}

// MARK: - Enemy Laser 3D (for separate handling)
class EnemyLaser3D: Laser3D {
    init(from startPosition: CGPoint, direction: CGPoint) {
        super.init(from: startPosition, direction: direction, type: .enemy)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Explosion Effects 3D
class ExplosionEffect3D: SKNode {
    private var creationTime: TimeInterval
    private let explosionType: ExplosionType
    private var mainExplosion: SKEmitterNode!
    private var secondaryEffects: [SKEmitterNode] = []
    
    enum ExplosionType {
        case small, enemy, mothership, powerUp
    }
    
    init(at position: CGPoint, type: ExplosionType) {
        self.creationTime = CACurrentMediaTime()
        self.explosionType = type
        
        super.init()
        self.position = position
        
        createMainExplosion(type: type)
        createSecondaryEffects(type: type)
        
        // Auto-remove after animation
        let duration = getDuration(for: type)
        run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.removeFromParent()
        ]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createMainExplosion(type: ExplosionType) {
        mainExplosion = SKEmitterNode()
        mainExplosion.particleTexture = SKTexture(imageNamed: "spark")
        
        switch type {
        case .small:
            configureSmallExplosion()
        case .enemy:
            configureEnemyExplosion()
        case .mothership:
            configureMothershipExplosion()
        case .powerUp:
            configurePowerUpExplosion()
        }
        
        addChild(mainExplosion)
    }
    
    private func configureSmallExplosion() {
        mainExplosion.particleLifetime = 0.8
        mainExplosion.particleBirthRate = 200
        mainExplosion.numParticlesToEmit = 30
        mainExplosion.particlePositionRange = CGVector(dx: 20, dy: 20)
        mainExplosion.particleSpeed = 100
        mainExplosion.particleSpeedRange = 50
        mainExplosion.emissionAngleRange = 2 * CGFloat.pi
        mainExplosion.particleColor = .yellow
        mainExplosion.particleColorBlendFactor = 0.8
        mainExplosion.particleAlpha = 0.9
        mainExplosion.particleAlphaSpeed = -1.2
        mainExplosion.particleScale = 0.3
        mainExplosion.particleScaleSpeed = -0.3
    }
    
    private func configureEnemyExplosion() {
        mainExplosion.particleLifetime = 1.2
        mainExplosion.particleBirthRate = 300
        mainExplosion.numParticlesToEmit = 60
        mainExplosion.particlePositionRange = CGVector(dx: 40, dy: 40)
        mainExplosion.particleSpeed = 150
        mainExplosion.particleSpeedRange = 100
        mainExplosion.emissionAngleRange = 2 * CGFloat.pi
        mainExplosion.particleColor = .orange
        mainExplosion.particleColorBlendFactor = 0.9
        mainExplosion.particleAlpha = 1.0
        mainExplosion.particleAlphaSpeed = -0.8
        mainExplosion.particleScale = 0.5
        mainExplosion.particleScaleSpeed = -0.4
    }
    
    private func configureMothershipExplosion() {
        mainExplosion.particleLifetime = 2.0
        mainExplosion.particleBirthRate = 500
        mainExplosion.numParticlesToEmit = 200
        mainExplosion.particlePositionRange = CGVector(dx: 100, dy: 100)
        mainExplosion.particleSpeed = 250
        mainExplosion.particleSpeedRange = 200
        mainExplosion.emissionAngleRange = 2 * CGFloat.pi
        mainExplosion.particleColor = .red
        mainExplosion.particleColorBlendFactor = 1.0
        mainExplosion.particleAlpha = 1.0
        mainExplosion.particleAlphaSpeed = -0.5
        mainExplosion.particleScale = 0.8
        mainExplosion.particleScaleSpeed = -0.3
    }
    
    private func configurePowerUpExplosion() {
        mainExplosion.particleLifetime = 1.0
        mainExplosion.particleBirthRate = 150
        mainExplosion.numParticlesToEmit = 40
        mainExplosion.particlePositionRange = CGVector(dx: 30, dy: 30)
        mainExplosion.particleSpeed = 80
        mainExplosion.particleSpeedRange = 60
        mainExplosion.emissionAngleRange = 2 * CGFloat.pi
        mainExplosion.particleColor = .magenta
        mainExplosion.particleColorBlendFactor = 0.9
        mainExplosion.particleAlpha = 0.8
        mainExplosion.particleAlphaSpeed = -0.8
        mainExplosion.particleScale = 0.4
        mainExplosion.particleScaleSpeed = -0.2
    }
    
    private func createSecondaryEffects(type: ExplosionType) {
        switch type {
        case .enemy:
            // Add shockwave effect
            createShockwave()
            // Add sparks
            createSparks()
        case .mothership:
            // Add shockwave effect
            createShockwave()
            // Add sparks
            createSparks()
            // Additional effects for mothership
            createDebrisField()
        default:
            break
        }
    }
    
    private func createShockwave() {
        let shockwave = SKShapeNode(circleOfRadius: 1)
        shockwave.strokeColor = .white
        shockwave.lineWidth = 3
        shockwave.fillColor = .clear
        shockwave.alpha = 0.8
        shockwave.zPosition = -1
        addChild(shockwave)
        
        let expand = SKAction.scale(to: explosionType == .mothership ? 200 : 100, duration: 0.8)
        let fade = SKAction.fadeOut(withDuration: 0.8)
        let remove = SKAction.removeFromParent()
        
        shockwave.run(SKAction.sequence([
            SKAction.group([expand, fade]),
            remove
        ]))
    }
    
    private func createSparks() {
        let sparks = SKEmitterNode()
        sparks.particleTexture = SKTexture(imageNamed: "spark")
        sparks.particleLifetime = 1.5
        sparks.particleBirthRate = 100
        sparks.numParticlesToEmit = 25
        sparks.particlePositionRange = CGVector(dx: 10, dy: 10)
        sparks.particleSpeed = 200
        sparks.particleSpeedRange = 150
        sparks.emissionAngleRange = 2 * CGFloat.pi
        sparks.particleColor = .white
        sparks.particleAlpha = 1.0
        sparks.particleAlphaSpeed = -0.7
        sparks.particleScale = 0.2
        sparks.particleScaleSpeed = -0.1
        sparks.zPosition = 1
        
        addChild(sparks)
        secondaryEffects.append(sparks)
    }
    
    private func createDebrisField() {
        for _ in 0..<15 {
            let debris = SKSpriteNode(color: .gray, size: CGSize(width: 4, height: 4))
            debris.position = CGPoint(
                x: CGFloat.random(in: -50...50),
                y: CGFloat.random(in: -50...50)
            )
            debris.alpha = 0.7
            addChild(debris)
            
            let velocity = CGVector(
                dx: CGFloat.random(in: -200...200),
                dy: CGFloat.random(in: -200...200)
            )
            
            let moveAction = SKAction.move(by: velocity, duration: 2.0)
            let fadeAction = SKAction.fadeOut(withDuration: 2.0)
            let rotateAction = SKAction.rotate(byAngle: CGFloat.random(in: -CGFloat.pi...CGFloat.pi), duration: 2.0)
            
            debris.run(SKAction.group([moveAction, fadeAction, rotateAction])) {
                debris.removeFromParent()
            }
        }
    }
    
    private func getDuration(for type: ExplosionType) -> TimeInterval {
        switch type {
        case .small:
            return 1.0
        case .enemy, .powerUp:
            return 1.5
        case .mothership:
            return 3.0
        }
    }
    
    var isFinished: Bool {
        return CACurrentMediaTime() - creationTime > getDuration(for: explosionType)
    }
}

// MARK: - Power-up Effects 3D
class PowerUp3D: SKSpriteNode {
    let powerType: PowerUpType
    private var rotationSpeed: CGFloat
    private var floatAmplitude: CGFloat = 10
    private var floatPhase: CGFloat = 0
    private var creationTime: TimeInterval
    private var lifetime: TimeInterval = 15.0
    private var pulseEffect: SKEffectNode!
    
    init(at position: CGPoint) {
        self.powerType = PowerUpType.allCases.randomElement()!
        self.rotationSpeed = CGFloat.random(in: 0.02...0.05)
        self.creationTime = CACurrentMediaTime()
        self.floatPhase = CGFloat.random(in: 0...(2 * CGFloat.pi))
        
        // Determine color before super.init
        let powerColor: UIColor
        switch powerType {
        case .extraLife:
            powerColor = .green
        case .rapidFire:
            powerColor = .yellow
        case .shield:
            powerColor = .cyan
        case .tripleShot:
            powerColor = .magenta
        }
        
        let texture = SKTexture(imageNamed: "spark")
        super.init(texture: texture, color: powerColor, size: CGSize(width: 20, height: 20))
        
        self.position = position
        colorBlendFactor = 0.8
        
        setupPhysics()
        createVisualEffects()
        createAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getPowerUpColor() -> UIColor {
        switch powerType {
        case .extraLife:
            return .green
        case .rapidFire:
            return .yellow
        case .shield:
            return .cyan
        case .tripleShot:
            return .magenta
        }
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        physicsBody?.categoryBitMask = 0x1 << 3 // powerUpCategory
        physicsBody?.contactTestBitMask = 0x1 << 0 // player
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = false
    }
    
    private func createVisualEffects() {
        // Glow effect
        pulseEffect = SKEffectNode()
        pulseEffect.shouldRasterize = true
        pulseEffect.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 8])
        
        let glowSprite = SKSpriteNode(texture: texture, size: CGSize(width: size.width * 2, height: size.height * 2))
        glowSprite.color = getPowerUpColor()
        glowSprite.colorBlendFactor = 1.0
        glowSprite.alpha = 0.6
        pulseEffect.addChild(glowSprite)
        pulseEffect.zPosition = -1
        addChild(pulseEffect)
        
        // Particle aura
        let aura = SKEmitterNode()
        aura.particleTexture = SKTexture(imageNamed: "spark")
        aura.particleLifetime = 1.5
        aura.particleBirthRate = 20
        aura.particlePositionRange = CGVector(dx: size.width, dy: size.height)
        aura.particleSpeed = 20
        aura.particleSpeedRange = 15
        aura.emissionAngleRange = 2 * CGFloat.pi
        aura.particleColor = getPowerUpColor()
        aura.particleColorBlendFactor = 0.8
        aura.particleAlpha = 0.4
        aura.particleAlphaSpeed = -0.3
        aura.particleScale = 0.3
        aura.particleScaleSpeed = 0.1
        aura.zPosition = -2
        
        addChild(aura)
    }
    
    private func createAnimations() {
        // Rotation
        let rotate = SKAction.rotate(byAngle: 2 * CGFloat.pi, duration: 3.0)
        run(SKAction.repeatForever(rotate))
        
        // Pulsing glow
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 1.0),
            SKAction.fadeAlpha(to: 1.0, duration: 1.0)
        ])
        pulseEffect.run(SKAction.repeatForever(pulse))
        
        // Scale breathing
        let breathe = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 1.5),
            SKAction.scale(to: 0.8, duration: 1.5)
        ])
        run(SKAction.repeatForever(breathe))
    }
    
    func update(_ currentTime: TimeInterval) {
        // Floating motion
        floatPhase += 0.03
        let floatOffset = sin(floatPhase) * floatAmplitude
        position.y += floatOffset * 0.01
        
        // Check lifetime
        if currentTime - creationTime > lifetime {
            // Fade out and remove
            let fadeOut = SKAction.fadeOut(withDuration: 1.0)
            let remove = SKAction.removeFromParent()
            run(SKAction.sequence([fadeOut, remove]))
        }
    }
}