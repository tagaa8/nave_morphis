import SpriteKit
import GameplayKit

// MARK: - Main Game Arena
class GameArena: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Game Properties
    private var score = 0
    private var lives = 5
    private var wave = 1
    private var combo = 0
    private var gameState: GameState = .playing
    
    // MARK: - Arena Elements
    private var arenaBackground: SKSpriteNode!
    private var arenaWalls: [SKNode] = []
    private var gridEffect: SKNode!
    
    // MARK: - Player
    private var playerShip: PlayerShipNode!
    private var playerSpeed: CGFloat = 400
    private var playerRotationSpeed: CGFloat = 3.0
    private var isAccelerating = false
    private var isTurningLeft = false
    private var isTurningRight = false
    private var isFiring = false
    private var lastFireTime: TimeInterval = 0
    private var fireRate: TimeInterval = 0.2
    
    // MARK: - Enemies
    private var enemies: Set<EnemyShipNode> = []
    private var maxEnemies = 3
    private var enemySpawnTimer: TimeInterval = 0
    private var enemySpawnRate: TimeInterval = 3.0
    
    // MARK: - Projectiles
    private var playerBullets: Set<BulletNode> = []
    private var enemyBullets: Set<BulletNode> = []
    
    // MARK: - Effects
    private var explosions: Set<ExplosionNode> = []
    private var powerUps: Set<PowerUpNode> = []
    
    // MARK: - UI
    private var scoreLabel: SKLabelNode!
    private var livesLabel: SKLabelNode!
    private var waveLabel: SKLabelNode!
    private var comboLabel: SKLabelNode!
    private var gameOverLabel: SKLabelNode!
    
    // MARK: - Touch Controls
    private var virtualJoystick: VirtualJoystick!
    private var fireButton: FireButton!
    private var leftTouch: UITouch?
    private var rightTouch: UITouch?
    
    // MARK: - Physics Categories
    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let player: UInt32 = 0x1 << 0
        static let enemy: UInt32 = 0x1 << 1
        static let playerBullet: UInt32 = 0x1 << 2
        static let enemyBullet: UInt32 = 0x1 << 3
        static let wall: UInt32 = 0x1 << 4
        static let powerUp: UInt32 = 0x1 << 5
    }
    
    enum GameState {
        case menu, playing, paused, gameOver
    }
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        setupPhysics()
        setupArena()
        setupPlayer()
        setupUI()
        setupControls()
        startGame()
    }
    
    private func setupPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
    }
    
    private func setupArena() {
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0)
        
        // Main arena background (the purple map)
        arenaBackground = SKSpriteNode(imageNamed: "mothership_or_map")
        arenaBackground.size = CGSize(width: size.width * 0.9, height: size.height * 0.85)
        arenaBackground.position = CGPoint(x: frame.midX, y: frame.midY)
        arenaBackground.zPosition = -10
        arenaBackground.alpha = 0.3
        addChild(arenaBackground)
        
        // Create grid effect overlay
        createGridEffect()
        
        // Create arena walls
        createArenaWalls()
        
        // Add animated background elements
        createBackgroundEffects()
    }
    
    private func createGridEffect() {
        gridEffect = SKNode()
        gridEffect.zPosition = -5
        
        let gridSize: CGFloat = 50
        let lineWidth: CGFloat = 1
        
        // Vertical lines
        for x in stride(from: 0, through: size.width, by: gridSize) {
            let line = SKShapeNode(rect: CGRect(x: x, y: 0, width: lineWidth, height: size.height))
            line.fillColor = .cyan
            line.strokeColor = .clear
            line.alpha = 0.1
            gridEffect.addChild(line)
        }
        
        // Horizontal lines
        for y in stride(from: 0, through: size.height, by: gridSize) {
            let line = SKShapeNode(rect: CGRect(x: 0, y: y, width: size.width, height: lineWidth))
            line.fillColor = .cyan
            line.strokeColor = .clear
            line.alpha = 0.1
            gridEffect.addChild(line)
        }
        
        addChild(gridEffect)
        
        // Animate grid
        let fadeOut = SKAction.fadeAlpha(to: 0.05, duration: 2.0)
        let fadeIn = SKAction.fadeAlpha(to: 0.15, duration: 2.0)
        let pulse = SKAction.sequence([fadeOut, fadeIn])
        gridEffect.run(SKAction.repeatForever(pulse))
    }
    
    private func createArenaWalls() {
        let wallThickness: CGFloat = 20
        
        // Top wall
        let topWall = SKNode()
        topWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: wallThickness))
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        topWall.position = CGPoint(x: frame.midX, y: frame.maxY - wallThickness/2)
        arenaWalls.append(topWall)
        addChild(topWall)
        
        // Bottom wall
        let bottomWall = SKNode()
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: wallThickness))
        bottomWall.physicsBody?.isDynamic = false
        bottomWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        bottomWall.position = CGPoint(x: frame.midX, y: wallThickness/2)
        arenaWalls.append(bottomWall)
        addChild(bottomWall)
        
        // Left wall
        let leftWall = SKNode()
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: size.height))
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        leftWall.position = CGPoint(x: wallThickness/2, y: frame.midY)
        arenaWalls.append(leftWall)
        addChild(leftWall)
        
        // Right wall
        let rightWall = SKNode()
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: size.height))
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        rightWall.position = CGPoint(x: frame.maxX - wallThickness/2, y: frame.midY)
        arenaWalls.append(rightWall)
        addChild(rightWall)
    }
    
    private func createBackgroundEffects() {
        // Floating particles
        for _ in 0..<20 {
            let particle = SKShapeNode(circleOfRadius: 2)
            particle.fillColor = .cyan
            particle.strokeColor = .clear
            particle.alpha = 0.3
            particle.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            particle.zPosition = -8
            addChild(particle)
            
            // Random floating animation
            let moveX = SKAction.moveBy(x: CGFloat.random(in: -50...50), y: 0, duration: Double.random(in: 3...6))
            let moveY = SKAction.moveBy(x: 0, y: CGFloat.random(in: -50...50), duration: Double.random(in: 3...6))
            let moveBack = SKAction.move(to: particle.position, duration: Double.random(in: 3...6))
            let sequence = SKAction.sequence([moveX, moveY, moveBack])
            particle.run(SKAction.repeatForever(sequence))
        }
    }
    
    private func setupPlayer() {
        playerShip = PlayerShipNode()
        playerShip.position = CGPoint(x: frame.midX, y: frame.height * 0.3)
        playerShip.zPosition = 10
        addChild(playerShip)
    }
    
    private func setupUI() {
        // Score
        scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .cyan
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 20, y: size.height - 40)
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
        
        // Lives
        livesLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        livesLabel.text = "LIVES: ♦♦♦♦♦"
        livesLabel.fontSize = 24
        livesLabel.fontColor = .green
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.position = CGPoint(x: size.width - 20, y: size.height - 40)
        livesLabel.zPosition = 100
        addChild(livesLabel)
        
        // Wave
        waveLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        waveLabel.text = "WAVE 1"
        waveLabel.fontSize = 24
        waveLabel.fontColor = .yellow
        waveLabel.position = CGPoint(x: frame.midX, y: size.height - 40)
        waveLabel.zPosition = 100
        addChild(waveLabel)
        
        // Combo (hidden initially)
        comboLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        comboLabel.text = ""
        comboLabel.fontSize = 32
        comboLabel.fontColor = .orange
        comboLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        comboLabel.zPosition = 100
        comboLabel.alpha = 0
        addChild(comboLabel)
    }
    
    private func setupControls() {
        // Virtual joystick (left side)
        virtualJoystick = VirtualJoystick(size: CGSize(width: 150, height: 150))
        virtualJoystick.position = CGPoint(x: 120, y: 120)
        virtualJoystick.zPosition = 200
        addChild(virtualJoystick)
        
        // Fire button (right side)
        fireButton = FireButton(size: CGSize(width: 100, height: 100))
        fireButton.position = CGPoint(x: size.width - 120, y: 120)
        fireButton.zPosition = 200
        addChild(fireButton)
    }
    
    private func startGame() {
        gameState = .playing
        score = 0
        lives = 5
        wave = 1
        combo = 0
    }
    
    // MARK: - Game Loop
    
    override func update(_ currentTime: TimeInterval) {
        guard gameState == .playing else { return }
        
        updatePlayer(currentTime)
        updateEnemies(currentTime)
        updateBullets()
        updateEffects()
        spawnEnemies(currentTime)
        checkWaveProgress()
        updateUI()
        cleanup()
    }
    
    private func updatePlayer(_ currentTime: TimeInterval) {
        // Get joystick input
        let joystickVector = virtualJoystick.getVector()
        
        if joystickVector != .zero {
            // Move player based on joystick
            let moveSpeed = playerSpeed * CGFloat(1.0/60.0) // Assuming 60 FPS
            playerShip.position.x += joystickVector.dx * moveSpeed
            playerShip.position.y += joystickVector.dy * moveSpeed
            
            // Rotate to face movement direction
            let angle = atan2(joystickVector.dy, joystickVector.dx) + CGFloat.pi/2
            playerShip.zRotation = angle
            
            // Add thrust effect
            playerShip.showThrust(true)
        } else {
            playerShip.showThrust(false)
        }
        
        // Keep player in bounds
        playerShip.position.x = max(50, min(size.width - 50, playerShip.position.x))
        playerShip.position.y = max(50, min(size.height - 50, playerShip.position.y))
        
        // Fire if button is pressed
        if fireButton.isPressed && currentTime - lastFireTime > fireRate {
            firePlayerBullet()
            lastFireTime = currentTime
        }
    }
    
    private func firePlayerBullet() {
        let bullet = BulletNode(type: .player)
        bullet.position = playerShip.position
        bullet.zRotation = playerShip.zRotation
        
        // Set velocity based on ship rotation
        let dx = sin(-playerShip.zRotation) * 500
        let dy = cos(-playerShip.zRotation) * 500
        bullet.physicsBody?.velocity = CGVector(dx: dx, dy: dy)
        
        playerBullets.insert(bullet)
        addChild(bullet)
        
        // Fire sound effect (placeholder)
        // run(SKAction.playSoundFileNamed("laser.wav", waitForCompletion: false))
    }
    
    private func updateEnemies(_ currentTime: TimeInterval) {
        for enemy in enemies {
            enemy.update(playerPosition: playerShip.position, currentTime: currentTime)
            
            // Check if enemy should fire
            if enemy.shouldFire(currentTime: currentTime) {
                fireEnemyBullet(from: enemy)
            }
        }
    }
    
    private func fireEnemyBullet(from enemy: EnemyShipNode) {
        let bullet = BulletNode(type: .enemy)
        bullet.position = enemy.position
        
        // Aim at player
        let dx = playerShip.position.x - enemy.position.x
        let dy = playerShip.position.y - enemy.position.y
        let angle = atan2(dy, dx)
        bullet.zRotation = angle - CGFloat.pi/2
        
        // Set velocity
        let speed: CGFloat = 300
        bullet.physicsBody?.velocity = CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)
        
        enemyBullets.insert(bullet)
        addChild(bullet)
    }
    
    private func updateBullets() {
        // Update player bullets
        for bullet in playerBullets {
            bullet.update()
        }
        
        // Update enemy bullets
        for bullet in enemyBullets {
            bullet.update()
        }
    }
    
    private func updateEffects() {
        // Update explosions
        for explosion in explosions {
            explosion.update()
            if explosion.isFinished {
                explosion.removeFromParent()
                explosions.remove(explosion)
            }
        }
        
        // Update power-ups
        for powerUp in powerUps {
            powerUp.update()
        }
    }
    
    private func spawnEnemies(_ currentTime: TimeInterval) {
        guard enemies.count < maxEnemies else { return }
        
        if currentTime - enemySpawnTimer > enemySpawnRate {
            let enemy = EnemyShipNode()
            
            // Spawn from random edge
            let edge = Int.random(in: 0...3)
            switch edge {
            case 0: // Top
                enemy.position = CGPoint(x: CGFloat.random(in: 100...size.width-100), y: size.height - 100)
            case 1: // Right
                enemy.position = CGPoint(x: size.width - 100, y: CGFloat.random(in: 100...size.height-100))
            case 2: // Bottom
                enemy.position = CGPoint(x: CGFloat.random(in: 100...size.width-100), y: 100)
            default: // Left
                enemy.position = CGPoint(x: 100, y: CGFloat.random(in: 100...size.height-100))
            }
            
            enemy.zPosition = 10
            enemies.insert(enemy)
            addChild(enemy)
            
            enemySpawnTimer = currentTime
        }
    }
    
    private func checkWaveProgress() {
        if score >= wave * 1000 {
            wave += 1
            waveLabel.text = "WAVE \(wave)"
            
            // Increase difficulty
            maxEnemies = min(10, 3 + wave)
            enemySpawnRate = max(1.0, 3.0 - Double(wave) * 0.2)
            
            // Wave complete effect
            showWaveComplete()
        }
    }
    
    private func showWaveComplete() {
        let waveText = SKLabelNode(fontNamed: "Helvetica-Bold")
        waveText.text = "WAVE \(wave) COMPLETE!"
        waveText.fontSize = 48
        waveText.fontColor = .yellow
        waveText.position = CGPoint(x: frame.midX, y: frame.midY)
        waveText.zPosition = 150
        waveText.setScale(0)
        addChild(waveText)
        
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let wait = SKAction.wait(forDuration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        
        waveText.run(SKAction.sequence([scaleUp, wait, fadeOut, remove]))
    }
    
    private func updateUI() {
        scoreLabel.text = "SCORE: \(score)"
        waveLabel.text = "WAVE \(wave)"
        
        // Update lives display
        var livesText = "LIVES: "
        for _ in 0..<lives {
            livesText += "♦"
        }
        livesLabel.text = livesText
        
        // Update combo
        if combo > 1 {
            comboLabel.text = "COMBO x\(combo)"
            comboLabel.alpha = 1.0
            comboLabel.removeAllActions()
            comboLabel.run(SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.fadeOut(withDuration: 0.5)
            ]))
        }
    }
    
    private func cleanup() {
        // Remove off-screen bullets
        playerBullets = playerBullets.filter { bullet in
            if !frame.contains(bullet.position) {
                bullet.removeFromParent()
                return false
            }
            return true
        }
        
        enemyBullets = enemyBullets.filter { bullet in
            if !frame.contains(bullet.position) {
                bullet.removeFromParent()
                return false
            }
            return true
        }
        
        // Remove collected power-ups
        powerUps = powerUps.filter { powerUp in
            if powerUp.isCollected {
                powerUp.removeFromParent()
                return false
            }
            return true
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if location.x < frame.midX {
                // Left side - joystick
                leftTouch = touch
                virtualJoystick.touchBegan(location)
            } else {
                // Right side - fire button
                rightTouch = touch
                fireButton.touchBegan(location)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if touch == leftTouch {
                virtualJoystick.touchMoved(location)
            } else if touch == rightTouch {
                fireButton.touchMoved(location)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == leftTouch {
                leftTouch = nil
                virtualJoystick.touchEnded()
            } else if touch == rightTouch {
                rightTouch = nil
                fireButton.touchEnded()
            }
        }
    }
    
    // MARK: - Physics Collision
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Player bullet hits enemy
        if collision == PhysicsCategory.playerBullet | PhysicsCategory.enemy {
            let bullet = contact.bodyA.categoryBitMask == PhysicsCategory.playerBullet ? contact.bodyA.node : contact.bodyB.node
            let enemy = contact.bodyA.categoryBitMask == PhysicsCategory.enemy ? contact.bodyA.node : contact.bodyB.node
            
            handlePlayerBulletHitEnemy(bullet: bullet as? BulletNode, enemy: enemy as? EnemyShipNode)
        }
        
        // Enemy bullet hits player
        else if collision == PhysicsCategory.enemyBullet | PhysicsCategory.player {
            let bullet = contact.bodyA.categoryBitMask == PhysicsCategory.enemyBullet ? contact.bodyA.node : contact.bodyB.node
            let player = contact.bodyA.categoryBitMask == PhysicsCategory.player ? contact.bodyA.node : contact.bodyB.node
            
            handleEnemyBulletHitPlayer(bullet: bullet as? BulletNode)
        }
        
        // Player collects power-up
        else if collision == PhysicsCategory.player | PhysicsCategory.powerUp {
            let powerUp = contact.bodyA.categoryBitMask == PhysicsCategory.powerUp ? contact.bodyA.node : contact.bodyB.node
            
            handlePowerUpCollection(powerUp: powerUp as? PowerUpNode)
        }
        
        // Enemy hits player
        else if collision == PhysicsCategory.player | PhysicsCategory.enemy {
            let enemy = contact.bodyA.categoryBitMask == PhysicsCategory.enemy ? contact.bodyA.node : contact.bodyB.node
            
            handleEnemyHitPlayer(enemy: enemy as? EnemyShipNode)
        }
    }
    
    private func handlePlayerBulletHitEnemy(bullet: BulletNode?, enemy: EnemyShipNode?) {
        guard let bullet = bullet, let enemy = enemy else { return }
        
        // Remove bullet
        bullet.removeFromParent()
        playerBullets.remove(bullet)
        
        // Damage enemy
        enemy.takeDamage(25)
        
        if enemy.isDestroyed {
            // Remove enemy
            enemy.removeFromParent()
            enemies.remove(enemy)
            
            // Create explosion
            let explosion = ExplosionNode(type: .enemy)
            explosion.position = enemy.position
            explosion.zPosition = 50
            explosions.insert(explosion)
            addChild(explosion)
            
            // Update score and combo
            combo += 1
            score += 100 * combo
            
            // Chance to spawn power-up
            if Int.random(in: 1...100) <= 20 {
                let powerUp = PowerUpNode(type: PowerUpNode.PowerUpType.allCases.randomElement()!)
                powerUp.position = enemy.position
                powerUp.zPosition = 15
                powerUps.insert(powerUp)
                addChild(powerUp)
            }
            
            // Sound effect (placeholder)
            // run(SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false))
        }
    }
    
    private func handleEnemyBulletHitPlayer(bullet: BulletNode?) {
        guard let bullet = bullet else { return }
        
        // Remove bullet
        bullet.removeFromParent()
        enemyBullets.remove(bullet)
        
        // Damage player
        if !playerShip.isInvulnerable {
            takeDamage()
        }
    }
    
    private func handleEnemyHitPlayer(enemy: EnemyShipNode?) {
        guard let enemy = enemy else { return }
        
        if !playerShip.isInvulnerable {
            // Remove enemy
            enemy.removeFromParent()
            enemies.remove(enemy)
            
            // Create explosion
            let explosion = ExplosionNode(type: .enemy)
            explosion.position = enemy.position
            explosion.zPosition = 50
            explosions.insert(explosion)
            addChild(explosion)
            
            // Damage player
            takeDamage()
        }
    }
    
    private func handlePowerUpCollection(powerUp: PowerUpNode?) {
        guard let powerUp = powerUp else { return }
        
        powerUp.collect()
        score += 50
        
        // Apply power-up effect
        switch powerUp.powerUpType {
        case .health:
            lives = min(5, lives + 1)
        case .rapidFire:
            fireRate = 0.1
            let waitAction = SKAction.wait(forDuration: 5.0)
            let resetAction = SKAction.run { [weak self] in
                self?.fireRate = 0.2
            }
            run(SKAction.sequence([waitAction, resetAction]))
        case .shield:
            playerShip.activateShield()
        case .tripleShot:
            // Implement triple shot
            break
        }
        
        // Sound effect (placeholder)
        // run(SKAction.playSoundFileNamed("powerup.wav", waitForCompletion: false))
    }
    
    private func takeDamage() {
        lives -= 1
        combo = 0
        
        // Flash effect
        playerShip.takeDamage()
        
        // Screen shake
        let shake = SKAction.sequence([
            SKAction.moveBy(x: 10, y: 0, duration: 0.05),
            SKAction.moveBy(x: -20, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05)
        ])
        run(shake)
        
        if lives <= 0 {
            gameOver()
        }
    }
    
    private func gameOver() {
        gameState = .gameOver
        
        // Show game over
        gameOverLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 64
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverLabel.zPosition = 200
        gameOverLabel.setScale(0)
        addChild(gameOverLabel)
        
        gameOverLabel.run(SKAction.scale(to: 1.0, duration: 0.5))
        
        // Transition to game over scene after delay
        let waitAction = SKAction.wait(forDuration: 2.0)
        let transitionAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            let gameOverScene = GameOverArena(size: self.size, finalScore: self.score, wave: self.wave)
            gameOverScene.scaleMode = self.scaleMode
            self.view?.presentScene(gameOverScene, transition: SKTransition.fade(withDuration: 1.0))
        }
        run(SKAction.sequence([waitAction, transitionAction]))
    }
}