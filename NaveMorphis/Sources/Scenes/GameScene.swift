import SpriteKit
import SwiftUI

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var player: PlayerShipNode?
    private var enemies: [EnemyShipNode] = []
    private var lasers: [LaserNode] = []
    private var powerUps: [PowerUpNode] = []
    private var mothership: MothershipNode?
    
    private var score: Int = 0
    private var wave: Int = 1
    private var lives: Int = 3
    private var isGamePaused: Bool = false
    private var lastUpdate: TimeInterval = 0
    
    private var leftThumbstick: CGPoint = CGPoint.zero
    private var rightThumbstick: CGPoint = CGPoint.zero
    private var autoFire: Bool = GameConfig.Controls.autoFireEnabled
    
    private var hudLabel: SKLabelNode?
    private var waveLabel: SKLabelNode?
    private var livesLabel: SKLabelNode?
    
    private var lastWaveTime: TimeInterval = 0
    private var lastEnemySpawn: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector.zero
        
        setupBackground()
        setupPlayer()
        setupHUD()
        setupBoundaries()
        
        startWave()
    }
    
    private func setupBackground() {
        backgroundColor = .black
        
        for i in 0..<GameConfig.Visual.parallaxLayers {
            let starLayer = createStarLayer(layer: i)
            addChild(starLayer)
        }
        
        let nebula = createNebula()
        addChild(nebula)
    }
    
    private func createStarLayer(layer: Int) -> SKEmitterNode {
        let stars = SKEmitterNode()
        stars.particleTexture = SKTexture(imageNamed: "spark")
        stars.particleBirthRate = CGFloat(20 + layer * 5)
        stars.particleLifetime = 20
        stars.particlePositionRange = CGVector(dx: size.width, dy: size.height)
        stars.particleSpeed = CGFloat(-30 - layer * 10)
        stars.particleSpeedRange = 20
        stars.particleScale = CGFloat(0.05 + Float(layer) * 0.02)
        stars.particleScaleRange = 0.02
        stars.particleColor = .white
        stars.particleAlpha = CGFloat(0.3 + Float(layer) * 0.15)
        stars.particleAlphaRange = 0.2
        stars.emissionAngle = 0
        stars.position = CGPoint(x: size.width, y: frame.midY)
        stars.zPosition = CGFloat(-10 + layer)
        
        return stars
    }
    
    private func createNebula() -> SKSpriteNode {
        let nebula = SKSpriteNode(color: .purple.withAlphaComponent(GameConfig.Visual.nebulaAlpha), size: CGSize(width: size.width * 2, height: size.height))
        nebula.position = CGPoint(x: frame.midX, y: frame.midY)
        nebula.zPosition = -5
        nebula.blendMode = .add
        
        let moveAction = SKAction.moveBy(x: -size.width * 2, y: 0, duration: 30)
        let resetAction = SKAction.moveBy(x: size.width * 4, y: 0, duration: 0)
        let sequenceAction = SKAction.sequence([moveAction, resetAction])
        nebula.run(SKAction.repeatForever(sequenceAction))
        
        return nebula
    }
    
    private func setupPlayer() {
        player = PlayerShipNode()
        player?.position = CGPoint(x: frame.midX, y: frame.midY - 200)
        
        if let player = player {
            addChild(player)
        }
    }
    
    private func setupHUD() {
        hudLabel = SKLabelNode(text: "Score: 0")
        hudLabel?.fontName = "Helvetica-Bold"
        hudLabel?.fontSize = 20
        hudLabel?.fontColor = .cyan
        hudLabel?.position = CGPoint(x: frame.minX + 100, y: frame.maxY - 50)
        hudLabel?.zPosition = 100
        
        waveLabel = SKLabelNode(text: "Wave: 1")
        waveLabel?.fontName = "Helvetica-Bold"
        waveLabel?.fontSize = 20
        waveLabel?.fontColor = .yellow
        waveLabel?.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        waveLabel?.zPosition = 100
        
        livesLabel = SKLabelNode(text: "Lives: 3")
        livesLabel?.fontName = "Helvetica-Bold"
        livesLabel?.fontSize = 20
        livesLabel?.fontColor = .red
        livesLabel?.position = CGPoint(x: frame.maxX - 100, y: frame.maxY - 50)
        livesLabel?.zPosition = 100
        
        if let hudLabel = hudLabel, let waveLabel = waveLabel, let livesLabel = livesLabel {
            addChild(hudLabel)
            addChild(waveLabel)
            addChild(livesLabel)
        }
    }
    
    private func setupBoundaries() {
        let boundary = SKPhysicsBody(edgeLoopFrom: frame.insetBy(dx: -50, dy: -50))
        boundary.categoryBitMask = PhysicsCategory.boundary
        boundary.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.enemy
        boundary.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy
        physicsBody = boundary
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdate == 0 {
            lastUpdate = currentTime
            return
        }
        
        let deltaTime = currentTime - lastUpdate
        lastUpdate = currentTime
        
        if isGamePaused { return }
        
        updatePlayer(deltaTime: deltaTime)
        updateEnemies(deltaTime: deltaTime)
        updateLasers(deltaTime: deltaTime)
        updatePowerUps(deltaTime: deltaTime)
        updateMothership(deltaTime: deltaTime)
        updateGameLogic(currentTime: currentTime, deltaTime: deltaTime)
        updateHUD()
        
        cleanupNodes()
    }
    
    private func updatePlayer(deltaTime: TimeInterval) {
        player?.update(deltaTime: deltaTime)
        
        if leftThumbstick != CGPoint.zero {
            let normalizedMovement = CGVector(
                dx: leftThumbstick.x / GameConfig.Controls.maxThumbstickRange,
                dy: leftThumbstick.y / GameConfig.Controls.maxThumbstickRange
            )
            player?.applyMovement(normalizedMovement, deltaTime: deltaTime)
        }
        
        if autoFire && rightThumbstick != CGPoint.zero {
            if let lasers = player?.fire() {
                for laser in lasers {
                    addChild(laser)
                    let direction = CGVector(dx: rightThumbstick.x, dy: rightThumbstick.y)
                    laser.fire(direction: direction)
                }
            }
        }
        
        wrapAroundScreen(node: player)
    }
    
    private func updateEnemies(deltaTime: TimeInterval) {
        for enemy in enemies {
            enemy.update(deltaTime: deltaTime, enemies: enemies)
            wrapAroundScreen(node: enemy)
        }
    }
    
    private func updateLasers(deltaTime: TimeInterval) {
        for laser in lasers {
            if !frame.insetBy(dx: -100, dy: -100).contains(laser.position) {
                laser.removeFromParent()
            }
        }
        
        lasers = lasers.filter { $0.parent != nil }
    }
    
    private func updatePowerUps(deltaTime: TimeInterval) {
        guard let player = player else { return }
        
        for powerUp in powerUps {
            powerUp.update(deltaTime: deltaTime, playerPosition: player.position)
        }
    }
    
    private func updateMothership(deltaTime: TimeInterval) {
        mothership?.update(deltaTime: deltaTime)
    }
    
    private func updateGameLogic(currentTime: TimeInterval, deltaTime: TimeInterval) {
        if currentTime - lastEnemySpawn > 3.0 && enemies.count < GameConfig.Game.maxEnemiesOnScreen {
            spawnEnemy()
            lastEnemySpawn = currentTime
        }
        
        if currentTime - lastWaveTime > GameConfig.Game.waveInterval {
            nextWave()
            lastWaveTime = currentTime
        }
        
        if enemies.isEmpty && mothership == nil && wave > 0 {
            if GameConfig.shouldSpawnBoss(wave: wave) {
                spawnMothership()
            } else {
                nextWave()
            }
        }
    }
    
    private func updateHUD() {
        hudLabel?.text = "Score: \(score)"
        waveLabel?.text = "Wave: \(wave)"
        livesLabel?.text = "Lives: \(lives)"
    }
    
    private func spawnEnemy() {
        let enemyType: EnemyType = Bool.random() ? .hunter : .sniper
        let enemy = EnemyShipNode(type: enemyType)
        
        let spawnSide = Int.random(in: 0...3)
        switch spawnSide {
        case 0:
            enemy.position = CGPoint(x: frame.minX - 50, y: CGFloat.random(in: frame.minY...frame.maxY))
        case 1:
            enemy.position = CGPoint(x: frame.maxX + 50, y: CGFloat.random(in: frame.minY...frame.maxY))
        case 2:
            enemy.position = CGPoint(x: CGFloat.random(in: frame.minX...frame.maxX), y: frame.minY - 50)
        case 3:
            enemy.position = CGPoint(x: CGFloat.random(in: frame.minX...frame.maxX), y: frame.maxY + 50)
        default:
            break
        }
        
        enemy.setTarget(player!)
        enemies.append(enemy)
        addChild(enemy)
    }
    
    private func spawnMothership() {
        mothership = MothershipNode()
        mothership?.position = CGPoint(x: frame.midX, y: frame.maxY - 150)
        mothership?.setTarget(player!)
        
        if let mothership = mothership {
            addChild(mothership)
        }
        
        SoundManager.shared.playSound(.mothershipEnraged)
    }
    
    private func startWave() {
        SoundManager.shared.playSound(.waveStart)
        lastWaveTime = CACurrentMediaTime()
        
        for _ in 0..<GameConfig.enemyCount(for: wave) {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...2)) {
                self.spawnEnemy()
            }
        }
    }
    
    private func nextWave() {
        wave += 1
        startWave()
    }
    
    private func wrapAroundScreen(node: SKNode?) {
        guard let node = node else { return }
        
        let buffer = GameConfig.Game.softWrapBoundary
        
        if node.position.x < frame.minX - buffer {
            node.position.x = frame.maxX + buffer
        } else if node.position.x > frame.maxX + buffer {
            node.position.x = frame.minX - buffer
        }
        
        if node.position.y < frame.minY - buffer {
            node.position.y = frame.maxY + buffer
        } else if node.position.y > frame.maxY + buffer {
            node.position.y = frame.minY - buffer
        }
    }
    
    private func cleanupNodes() {
        enemies = enemies.filter { $0.parent != nil }
        lasers = lasers.filter { $0.parent != nil }
        powerUps = powerUps.filter { $0.parent != nil }
    }
    
    func pauseGame() {
        isGamePaused = true
        isPaused = true
    }
    
    func resumeGame() {
        isGamePaused = false
        isPaused = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches, began: true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches, began: false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if location.x < frame.midX {
                leftThumbstick = CGPoint.zero
            } else {
                rightThumbstick = CGPoint.zero
            }
        }
    }
    
    private func handleTouches(_ touches: Set<UITouch>, began: Bool) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if location.x < frame.midX {
                if began {
                    leftThumbstick = CGPoint.zero
                }
                
                let previousLocation = touch.previousLocation(in: self)
                let deltaX = location.x - previousLocation.x
                let deltaY = location.y - previousLocation.y
                
                leftThumbstick = CGPoint(
                    x: min(max(leftThumbstick.x + deltaX, -GameConfig.Controls.maxThumbstickRange), GameConfig.Controls.maxThumbstickRange),
                    y: min(max(leftThumbstick.y + deltaY, -GameConfig.Controls.maxThumbstickRange), GameConfig.Controls.maxThumbstickRange)
                )
            } else {
                rightThumbstick = CGPoint(
                    x: location.x - frame.midX,
                    y: location.y - frame.midY
                )
                
                if !autoFire && began {
                    if let lasers = player?.fire() {
                        for laser in lasers {
                            addChild(laser)
                            let direction = CGVector(dx: rightThumbstick.x, dy: rightThumbstick.y)
                            laser.fire(direction: direction)
                        }
                    }
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        handleCollision(nodeA: bodyA.node, nodeB: bodyB.node, categoryA: bodyA.categoryBitMask, categoryB: bodyB.categoryBitMask)
    }
    
    private func handleCollision(nodeA: SKNode?, nodeB: SKNode?, categoryA: UInt32, categoryB: UInt32) {
        guard let nodeA = nodeA, let nodeB = nodeB else { return }
        
        if (categoryA == PhysicsCategory.player && categoryB == PhysicsCategory.laserEnemy) ||
           (categoryA == PhysicsCategory.laserEnemy && categoryB == PhysicsCategory.player) {
            
            let player = (nodeA as? PlayerShipNode) ?? (nodeB as? PlayerShipNode)
            let laser = (nodeA as? LaserNode) ?? (nodeB as? LaserNode)
            
            player?.takeDamage(laser?.damage ?? 10)
            laser?.hit()
            
        } else if (categoryA == PhysicsCategory.enemy && categoryB == PhysicsCategory.laserPlayer) ||
                  (categoryA == PhysicsCategory.laserPlayer && categoryB == PhysicsCategory.enemy) {
            
            let enemy = (nodeA as? EnemyShipNode) ?? (nodeB as? EnemyShipNode)
            let laser = (nodeA as? LaserNode) ?? (nodeB as? LaserNode)
            
            if let enemy = enemy, let laser = laser {
                if enemy.takeDamage(laser.damage) {
                    score += enemy.scoreValue
                }
                laser.hit()
            }
            
        } else if (categoryA == PhysicsCategory.player && categoryB == PhysicsCategory.powerUp) ||
                  (categoryA == PhysicsCategory.powerUp && categoryB == PhysicsCategory.player) {
            
            let player = (nodeA as? PlayerShipNode) ?? (nodeB as? PlayerShipNode)
            let powerUp = (nodeA as? PowerUpNode) ?? (nodeB as? PowerUpNode)
            
            if let powerUp = powerUp {
                applyPowerUp(powerUp, to: player)
                powerUp.collect()
            }
            
        } else if (categoryA == PhysicsCategory.mothership && categoryB == PhysicsCategory.laserPlayer) ||
                  (categoryA == PhysicsCategory.laserPlayer && categoryB == PhysicsCategory.mothership) {
            
            let mothership = (nodeA as? MothershipNode) ?? (nodeB as? MothershipNode)
            let module = (nodeA as? MothershipModule) ?? (nodeB as? MothershipModule)
            let laser = (nodeA as? LaserNode) ?? (nodeB as? LaserNode)
            
            if let laser = laser {
                if let module = module {
                    if module.takeDamage(laser.damage) {
                        score += 500
                        mothership?.moduleDestroyed()
                    }
                } else if let mothership = mothership {
                    if mothership.takeDamage(laser.damage) {
                        score += GameConfig.Mothership.scoreValue
                        gameWon()
                    }
                }
                laser.hit()
            }
        }
    }
    
    private func applyPowerUp(_ powerUp: PowerUpNode, to player: PlayerShipNode?) {
        guard let player = player else { return }
        
        switch powerUp.powerUpType {
        case .health:
            player.heal(GameConfig.PowerUp.healAmount)
        case .energy:
            player.restoreEnergy(GameConfig.PowerUp.energyAmount)
        case .shield:
            player.restoreShield(GameConfig.Player.maxShield)
        default:
            player.applyPowerUp(powerUp.powerUpType)
        }
    }
    
    private func gameWon() {
        SoundManager.shared.playSound(.victory)
        
        let transition = SKTransition.fade(withDuration: 1.0)
        let gameOverScene = GameOverScene(size: size, won: true, finalScore: score, wave: wave)
        gameOverScene.scaleMode = scaleMode
        
        view?.presentScene(gameOverScene, transition: transition)
    }
    
    private func gameOver() {
        SoundManager.shared.playSound(.gameOver)
        
        let transition = SKTransition.fade(withDuration: 1.0)
        let gameOverScene = GameOverScene(size: size, won: false, finalScore: score, wave: wave)
        gameOverScene.scaleMode = scaleMode
        
        view?.presentScene(gameOverScene, transition: transition)
    }
}