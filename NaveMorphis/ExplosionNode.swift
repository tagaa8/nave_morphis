import SpriteKit

class ExplosionNode: SKNode {
    
    enum ExplosionType {
        case enemy
        case player
        case powerUp
    }
    
    private let explosionType: ExplosionType
    var isFinished = false
    private var duration: TimeInterval = 0
    private let maxDuration: TimeInterval
    
    init(type: ExplosionType) {
        self.explosionType = type
        
        switch type {
        case .enemy:
            maxDuration = 0.8
        case .player:
            maxDuration = 1.2
        case .powerUp:
            maxDuration = 0.5
        }
        
        super.init()
        createExplosion()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createExplosion() {
        // Main explosion particles
        let mainExplosion = SKEmitterNode()
        mainExplosion.particleTexture = createExplosionTexture()
        
        switch explosionType {
        case .enemy:
            setupEnemyExplosion(mainExplosion)
        case .player:
            setupPlayerExplosion(mainExplosion)
        case .powerUp:
            setupPowerUpExplosion(mainExplosion)
        }
        
        addChild(mainExplosion)
        
        // Secondary explosion ring
        createExplosionRing()
        
        // Flash effect
        createFlash()
    }
    
    private func setupEnemyExplosion(_ emitter: SKEmitterNode) {
        emitter.particleLifetime = 0.6
        emitter.particleBirthRate = 200
        emitter.numParticlesToEmit = 50
        
        emitter.particlePositionRange = CGVector(dx: 20, dy: 20)
        emitter.emissionAngleRange = CGFloat.pi * 2
        
        emitter.particleSpeed = 150
        emitter.particleSpeedRange = 100
        
        emitter.particleScale = 0.5
        emitter.particleScaleRange = 0.3
        emitter.particleScaleSpeed = -0.5
        
        emitter.particleColor = .red
        emitter.particleColorSequence = createExplosionColorSequence(baseColor: .red)
        
        emitter.particleAlpha = 0.8
        emitter.particleAlphaSpeed = -1.3
    }
    
    private func setupPlayerExplosion(_ emitter: SKEmitterNode) {
        emitter.particleLifetime = 1.0
        emitter.particleBirthRate = 300
        emitter.numParticlesToEmit = 80
        
        emitter.particlePositionRange = CGVector(dx: 30, dy: 30)
        emitter.emissionAngleRange = CGFloat.pi * 2
        
        emitter.particleSpeed = 200
        emitter.particleSpeedRange = 150
        
        emitter.particleScale = 0.7
        emitter.particleScaleRange = 0.4
        emitter.particleScaleSpeed = -0.4
        
        emitter.particleColor = .cyan
        emitter.particleColorSequence = createExplosionColorSequence(baseColor: .cyan)
        
        emitter.particleAlpha = 0.9
        emitter.particleAlphaSpeed = -1.0
    }
    
    private func setupPowerUpExplosion(_ emitter: SKEmitterNode) {
        emitter.particleLifetime = 0.4
        emitter.particleBirthRate = 150
        emitter.numParticlesToEmit = 30
        
        emitter.particlePositionRange = CGVector(dx: 15, dy: 15)
        emitter.emissionAngleRange = CGFloat.pi * 2
        
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 50
        
        emitter.particleScale = 0.3
        emitter.particleScaleRange = 0.2
        emitter.particleScaleSpeed = -0.3
        
        emitter.particleColor = .yellow
        emitter.particleColorSequence = createExplosionColorSequence(baseColor: .yellow)
        
        emitter.particleAlpha = 0.7
        emitter.particleAlphaSpeed = -1.5
    }
    
    private func createExplosionColorSequence(baseColor: UIColor) -> SKKeyframeSequence? {
        let colors = [
            baseColor,
            UIColor.white,
            baseColor.withAlphaComponent(0.5),
            UIColor.clear
        ]
        
        let times = [0.0, 0.2, 0.6, 1.0] as [NSNumber]
        return SKKeyframeSequence(keyframeValues: colors, times: times)
    }
    
    private func createExplosionRing() {
        let ring = SKShapeNode(circleOfRadius: 5)
        ring.strokeColor = explosionType == .player ? .cyan : .red
        ring.lineWidth = 3
        ring.fillColor = .clear
        ring.alpha = 0.8
        addChild(ring)
        
        let expandAction = SKAction.scale(to: 8.0, duration: maxDuration * 0.7)
        let fadeAction = SKAction.fadeOut(withDuration: maxDuration * 0.7)
        let removeAction = SKAction.removeFromParent()
        
        ring.run(SKAction.sequence([
            SKAction.group([expandAction, fadeAction]),
            removeAction
        ]))
    }
    
    private func createFlash() {
        let flash = SKSpriteNode(color: .white, size: CGSize(width: 100, height: 100))
        flash.alpha = 0.8
        flash.zPosition = 10
        addChild(flash)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let remove = SKAction.removeFromParent()
        flash.run(SKAction.sequence([fadeOut, remove]))
    }
    
    func update() {
        duration += 1.0/60.0 // Assuming 60 FPS
        
        if duration >= maxDuration {
            isFinished = true
        }
    }
    
    private func createExplosionTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 8)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        return SKTexture(image: image)
    }
}