import SpriteKit

class PowerUpNode: SKSpriteNode {
    
    var powerUpType: PowerUpType = .health
    var magnetRange: CGFloat = GameConfig.PowerUp.magnetRange
    private var isBeingCollected: Bool = false
    private var glowNode: SKShapeNode?
    private var particles: SKEmitterNode?
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        setupPowerUp()
    }
    
    convenience init() {
        let size = CGSize(width: 30, height: 30)
        self.init(texture: nil, color: .clear, size: size)
        randomizePowerUp()
        setupPhysics()
        setupVisuals()
        setupAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPowerUp() {
        zPosition = 10
    }
    
    private func randomizePowerUp() {
        powerUpType = PowerUpType.allCases.randomElement() ?? .health
        
        switch powerUpType {
        case .health:
            color = .red
            texture = createPowerUpTexture(symbol: "+")
        case .energy:
            color = .blue
            texture = createPowerUpTexture(symbol: "⚡")
        case .shield:
            color = .cyan
            texture = createPowerUpTexture(symbol: "◊")
        case .damage:
            color = .orange
            texture = createPowerUpTexture(symbol: "⦿")
        case .rapidFire:
            color = .yellow
            texture = createPowerUpTexture(symbol: "≡")
        case .turbo:
            color = .green
            texture = createPowerUpTexture(symbol: "▶")
        case .morph:
            color = .magenta
            texture = createPowerUpTexture(symbol: "◈")
        }
        
        colorBlendFactor = 0.8
    }
    
    private func createPowerUpTexture(symbol: String) -> SKTexture {
        let size = CGSize(width: 30, height: 30)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            UIColor.white.setFill()
            UIBezierPath(ovalIn: rect).fill()
            
            color.setFill()
            UIBezierPath(ovalIn: rect.insetBy(dx: 2, dy: 2)).fill()
            
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.boldSystemFont(ofSize: 16)
            ]
            
            let attributedString = NSAttributedString(string: symbol, attributes: attributes)
            let stringRect = attributedString.boundingRect(with: size, options: [], context: nil)
            let drawPoint = CGPoint(
                x: (size.width - stringRect.width) / 2,
                y: (size.height - stringRect.height) / 2
            )
            
            attributedString.draw(at: drawPoint)
        }
        
        return SKTexture(image: image)
    }
    
    private func setupPhysics() {
        physicsBody = PhysicsHelper.createCircleBody(radius: size.width / 2)
        PhysicsHelper.configureBody(
            for: physicsBody!,
            category: PhysicsCategory.powerUp,
            contact: PhysicsCategory.player,
            collision: PhysicsCategory.none
        )
        physicsBody?.isDynamic = false
    }
    
    private func setupVisuals() {
        setupGlow()
        setupParticles()
    }
    
    private func setupGlow() {
        glowNode = SKShapeNode(circleOfRadius: size.width / 2 + 5)
        glowNode?.fillColor = .clear
        glowNode?.strokeColor = color
        glowNode?.lineWidth = 2
        glowNode?.alpha = 0.6
        glowNode?.glowWidth = 8
        
        if let glowNode = glowNode {
            addChild(glowNode)
        }
    }
    
    private func setupParticles() {
        particles = SKEmitterNode()
        particles?.particleTexture = SKTexture(imageNamed: "spark")
        particles?.particleBirthRate = 20
        particles?.particleLifetime = 1.0
        particles?.particleLifetimeRange = 0.5
        particles?.emissionAngleRange = CGFloat.pi * 2
        particles?.particleSpeed = 30
        particles?.particleSpeedRange = 15
        particles?.particleScale = 0.3
        particles?.particleScaleRange = 0.2
        particles?.particleAlpha = 0.8
        particles?.particleAlphaRange = 0.4
        particles?.particleAlphaSpeed = -0.8
        
        particles?.particleColorRed = color.cgColor.components?[0] ?? 1.0
        particles?.particleColorGreen = color.cgColor.components?[1] ?? 1.0
        particles?.particleColorBlue = color.cgColor.components?[2] ?? 1.0
        
        if let particles = particles {
            addChild(particles)
        }
    }
    
    private func setupAnimations() {
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 10, duration: 1.5),
            SKAction.moveBy(x: 0, y: -10, duration: 1.5)
        ])
        run(SKAction.repeatForever(float))
        
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 3.0)
        run(SKAction.repeatForever(rotate))
        
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])
        run(SKAction.repeatForever(pulse))
        
        let glowPulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.6),
            SKAction.fadeAlpha(to: 0.9, duration: 0.6)
        ])
        glowNode?.run(SKAction.repeatForever(glowPulse))
        
        let despawnAction = SKAction.sequence([
            SKAction.wait(forDuration: 10.0),
            SKAction.group([
                SKAction.fadeOut(withDuration: 1.0),
                SKAction.scale(to: 0, duration: 1.0)
            ]),
            SKAction.removeFromParent()
        ])
        run(despawnAction)
    }
    
    func update(deltaTime: TimeInterval, playerPosition: CGPoint) {
        guard !isBeingCollected else { return }
        
        let distance = distanceTo(point: playerPosition)
        
        if distance <= magnetRange {
            magnetTowardsPlayer(playerPosition: playerPosition, deltaTime: deltaTime)
        }
    }
    
    private func magnetTowardsPlayer(playerPosition: CGPoint, deltaTime: TimeInterval) {
        let direction = CGVector(
            dx: playerPosition.x - position.x,
            dy: playerPosition.y - position.y
        )
        
        let distance = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
        if distance > 0 {
            let magnetSpeed: CGFloat = 200
            let normalizedDirection = CGVector(
                dx: direction.dx / distance,
                dy: direction.dy / distance
            )
            
            let movement = CGVector(
                dx: normalizedDirection.dx * magnetSpeed * CGFloat(deltaTime),
                dy: normalizedDirection.dy * magnetSpeed * CGFloat(deltaTime)
            )
            
            position = CGPoint(
                x: position.x + movement.dx,
                y: position.y + movement.dy
            )
            
            particles?.particleBirthRate = 40
            glowNode?.alpha = 1.0
            
            let magnetEffect = createMagnetEffect()
            addChild(magnetEffect)
        }
    }
    
    private func createMagnetEffect() -> SKEmitterNode {
        let effect = SKEmitterNode()
        effect.particleTexture = SKTexture(imageNamed: "spark")
        effect.particleBirthRate = 10
        effect.particleLifetime = 0.5
        effect.particleLifetimeRange = 0.2
        effect.emissionAngleRange = CGFloat.pi * 2
        effect.particleSpeed = 50
        effect.particleSpeedRange = 25
        effect.particleScale = 0.2
        effect.particleScaleRange = 0.1
        effect.particleAlpha = 0.6
        effect.particleAlphaSpeed = -1.2
        effect.particleColorRed = 1.0
        effect.particleColorGreen = 1.0
        effect.particleColorBlue = 1.0
        
        let removeEffect = SKAction.sequence([
            SKAction.wait(forDuration: 0.8),
            SKAction.removeFromParent()
        ])
        effect.run(removeEffect)
        
        return effect
    }
    
    func collect() {
        guard !isBeingCollected else { return }
        
        isBeingCollected = true
        
        removeAllActions()
        
        let collectEffect = createCollectEffect()
        parent?.addChild(collectEffect)
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let remove = SKAction.removeFromParent()
        
        run(SKAction.sequence([
            SKAction.group([scaleUp, fadeOut]),
            remove
        ]))
        
        HapticManager.shared.playPowerUp()
        SoundManager.shared.playSound(.powerUpCollect)
    }
    
    private func createCollectEffect() -> SKEmitterNode {
        let effect = SKEmitterNode()
        effect.particleTexture = SKTexture(imageNamed: "spark")
        effect.particleBirthRate = 100
        effect.numParticlesToEmit = 25
        effect.particleLifetime = 0.8
        effect.particleLifetimeRange = 0.4
        effect.emissionAngleRange = CGFloat.pi * 2
        effect.particleSpeed = 100
        effect.particleSpeedRange = 50
        effect.particleScale = 0.5
        effect.particleScaleRange = 0.3
        effect.particleAlpha = 1.0
        effect.particleAlphaSpeed = -1.25
        
        effect.particleColorRed = color.cgColor.components?[0] ?? 1.0
        effect.particleColorGreen = color.cgColor.components?[1] ?? 1.0
        effect.particleColorBlue = color.cgColor.components?[2] ?? 1.0
        
        effect.position = position
        
        let removeEffect = SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ])
        effect.run(removeEffect)
        
        return effect
    }
    
    private func distanceTo(point: CGPoint) -> CGFloat {
        let dx = point.x - position.x
        let dy = point.y - position.y
        return sqrt(dx * dx + dy * dy)
    }
}