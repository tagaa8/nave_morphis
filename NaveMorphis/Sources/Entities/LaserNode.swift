import SpriteKit

class LaserNode: SKSpriteNode {
    
    var damage: CGFloat = 10
    var speed: CGFloat = 600
    var isPlayerLaser: Bool = false
    private var trail: SKEmitterNode?
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        setupLaser()
    }
    
    convenience init(isPlayerLaser: Bool) {
        let size = CGSize(width: 4, height: 20)
        self.init(texture: nil, color: isPlayerLaser ? .cyan : .red, size: size)
        self.isPlayerLaser = isPlayerLaser
        setupPhysics()
        setupTrail()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLaser() {
        colorBlendFactor = 1.0
        
        let glowNode = SKSpriteNode(texture: nil, color: color, size: CGSize(width: size.width * 2, height: size.height))
        glowNode.alpha = 0.3
        glowNode.blendMode = .add
        addChild(glowNode)
        
        let coreNode = SKSpriteNode(texture: nil, color: .white, size: CGSize(width: size.width * 0.5, height: size.height))
        addChild(coreNode)
    }
    
    private func setupPhysics() {
        physicsBody = PhysicsHelper.createRectangleBody(size: size)
        
        if isPlayerLaser {
            PhysicsHelper.configureBody(
                for: physicsBody!,
                category: PhysicsCategory.laserPlayer,
                contact: PhysicsCategory.enemy | PhysicsCategory.mothership,
                collision: PhysicsCategory.none
            )
        } else {
            PhysicsHelper.configureBody(
                for: physicsBody!,
                category: PhysicsCategory.laserEnemy,
                contact: PhysicsCategory.player | PhysicsCategory.shield,
                collision: PhysicsCategory.none
            )
        }
        
        physicsBody?.usesPreciseCollisionDetection = true
    }
    
    private func setupTrail() {
        trail = SKEmitterNode()
        trail?.particleTexture = SKTexture(imageNamed: "spark")
        trail?.particleBirthRate = 20
        trail?.particleLifetime = 0.3
        trail?.particleLifetimeRange = 0.1
        trail?.emissionAngle = CGFloat.pi
        trail?.emissionAngleRange = CGFloat.pi / 6
        trail?.particleSpeed = 50
        trail?.particleSpeedRange = 20
        trail?.particleScale = 0.3
        trail?.particleScaleRange = 0.1
        trail?.particleAlpha = 0.8
        trail?.particleAlphaRange = 0.3
        trail?.particleAlphaSpeed = -2.0
        
        if isPlayerLaser {
            trail?.particleColorRed = 0.0
            trail?.particleColorGreen = 1.0
            trail?.particleColorBlue = 1.0
        } else {
            trail?.particleColorRed = 1.0
            trail?.particleColorGreen = 0.0
            trail?.particleColorBlue = 0.0
        }
        
        trail?.position = CGPoint(x: 0, y: -size.height / 2)
        
        if let trail = trail {
            addChild(trail)
        }
    }
    
    func fire(direction: CGVector) {
        let normalizedDirection = normalize(direction)
        let velocity = CGVector(
            dx: normalizedDirection.dx * speed,
            dy: normalizedDirection.dy * speed
        )
        
        physicsBody?.velocity = velocity
        
        let angle = atan2(velocity.dy, velocity.dx) - CGFloat.pi / 2
        zRotation = angle
        
        let moveDistance = CGFloat(1000)
        let moveTime = TimeInterval(moveDistance / speed)
        
        let moveAction = SKAction.move(by: CGVector(dx: velocity.dx * moveTime, dy: velocity.dy * moveTime), duration: moveTime)
        let removeAction = SKAction.removeFromParent()
        
        run(SKAction.sequence([moveAction, removeAction]))
        
        createMuzzleFlash()
    }
    
    func fireTowards(target: CGPoint) {
        let direction = CGVector(
            dx: target.x - position.x,
            dy: target.y - position.y
        )
        fire(direction: direction)
    }
    
    private func createMuzzleFlash() {
        let flash = SKEmitterNode()
        flash.particleTexture = SKTexture(imageNamed: "spark")
        flash.particleBirthRate = 100
        flash.numParticlesToEmit = 20
        flash.particleLifetime = 0.2
        flash.particleLifetimeRange = 0.1
        flash.emissionAngleRange = CGFloat.pi * 2
        flash.particleSpeed = 100
        flash.particleSpeedRange = 50
        flash.particleScale = 0.5
        flash.particleScaleRange = 0.3
        flash.particleAlpha = 1.0
        flash.particleAlphaSpeed = -5.0
        
        if isPlayerLaser {
            flash.particleColorRed = 0.0
            flash.particleColorGreen = 1.0
            flash.particleColorBlue = 1.0
        } else {
            flash.particleColorRed = 1.0
            flash.particleColorGreen = 0.3
            flash.particleColorBlue = 0.0
        }
        
        flash.position = CGPoint(x: 0, y: size.height / 2)
        addChild(flash)
        
        let removeFlash = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.removeFromParent()
        ])
        flash.run(removeFlash)
    }
    
    func hit() {
        createHitEffect()
        removeFromParent()
    }
    
    private func createHitEffect() {
        let hit = SKEmitterNode()
        hit.particleTexture = SKTexture(imageNamed: "spark")
        hit.particleBirthRate = 50
        hit.numParticlesToEmit = 15
        hit.particleLifetime = 0.5
        hit.particleLifetimeRange = 0.2
        hit.emissionAngleRange = CGFloat.pi * 2
        hit.particleSpeed = 150
        hit.particleSpeedRange = 75
        hit.particleScale = 0.4
        hit.particleScaleRange = 0.2
        hit.particleAlpha = 1.0
        hit.particleAlphaSpeed = -2.0
        hit.particleColorRed = 1.0
        hit.particleColorGreen = 1.0
        hit.particleColorBlue = 0.0
        hit.position = position
        
        parent?.addChild(hit)
        
        let removeHit = SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ])
        hit.run(removeHit)
    }
    
    private func normalize(_ vector: CGVector) -> CGVector {
        let length = sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
        if length == 0 {
            return CGVector.zero
        }
        return CGVector(dx: vector.dx / length, dy: vector.dy / length)
    }
    
    deinit {
        trail?.removeFromParent()
    }
}