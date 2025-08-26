import SpriteKit
import GameplayKit

class GameScene3D: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Game State
    private var gameState: GameState = .menu
    private var score = 0
    private var lives = 3
    private var wave = 1
    private var combo = 0
    
    // MARK: - Player System
    private var playerShip: PlayerShip3D!
    private var leftThumbstick = CGPoint.zero
    private var rightThumbstick = CGPoint.zero
    private var autoFireEnabled = false
    private var lastAutoFire: TimeInterval = 0
    
    // MARK: - Enemy System
    private var enemies: Set<EnemyShip3D> = []
    private var lastEnemySpawn: TimeInterval = 0
    private let maxEnemies = 8
    private var enemySpawnRate: TimeInterval = 1.5
    
    // MARK: - Mothership Boss
    private var mothership: MothershipBoss?
    private var mothershipActive = false
    private var bossSpawnWave = 5
    
    // MARK: - Projectiles & Effects
    private var lasers: Set<Laser3D> = []
    private var explosions: Set<ExplosionEffect3D> = []
    private var powerUps: Set<PowerUp3D> = []
    
    // MARK: - Background & Environment
    private var starField: StarField3D!
    private var nebulae: [NebulaLayer] = []
    private var spaceDebris: Set<SpaceDebris> = []
    
    // MARK: - UI Elements
    private var scoreLabel: SKLabelNode!
    private var livesLabel: SKLabelNode!
    private var waveLabel: SKLabelNode!
    private var comboLabel: SKLabelNode!
    private var instructionsLabel: SKLabelNode!
    
    // MARK: - Audio System
    private var backgroundMusic: SKAudioNode?
    
    // MARK: - Physics Categories
    private let playerCategory: UInt32 = 0x1 << 0
    private let enemyCategory: UInt32 = 0x1 << 1
    private let laserCategory: UInt32 = 0x1 << 2
    private let powerUpCategory: UInt32 = 0x1 << 3
    private let mothershipCategory: UInt32 = 0x1 << 4
    private let debrisCategory: UInt32 = 0x1 << 5
    
    public enum GameState {
        case menu, playing, paused, gameOver, bossIntro
    }
    
    override func didMove(to view: SKView) {
        setupPhysics()
        setupBackground3D()
        setupAudioSystem()
        setupPlayer()
        setupUI()
        gameState = .playing
        
        // Start with epic space intro
        playIntroSequence()
    }
    
    // MARK: - Setup Methods
    
    private func setupPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector.zero
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = debrisCategory
    }
    
    private func setupBackground3D() {
        backgroundColor = .black
        
        // Multi-layer starfield with 3D depth
        starField = StarField3D(size: size)
        addChild(starField)
        
        // Create dynamic nebulae
        createNebulae()
        
        // Add space debris for depth
        createSpaceDebris()
    }
    
    private func createNebulae() {
        for i in 0..<3 {
            let nebula = NebulaLayer(
                size: size,
                depth: CGFloat(i + 1),
                color: [.purple, .cyan, .magenta][i],
                alpha: 0.1 - CGFloat(i) * 0.02
            )
            nebula.zPosition = -10 - CGFloat(i)
            addChild(nebula)
            nebulae.append(nebula)
        }
    }
    
    private func createSpaceDebris() {
        for _ in 0..<15 {
            let debris = SpaceDebris(size: size)
            addChild(debris)
            spaceDebris.insert(debris)
        }
    }
    
    private func setupAudioSystem() {
        // Simple background music setup
        // Note: Add "space_ambient.m4a" to project for background music
        /*
        if let musicPath = Bundle.main.path(forResource: "space_ambient", ofType: "m4a") {
            backgroundMusic = SKAudioNode(fileNamed: "space_ambient.m4a")
            backgroundMusic?.autoplayLooped = true
            addChild(backgroundMusic!)
        }
        */
    }
    
    private func setupPlayer() {
        playerShip = PlayerShip3D()
        playerShip.position = CGPoint(x: frame.midX, y: frame.midY)
        playerShip.zPosition = 100
        addChild(playerShip)
    }
    
    private func setupUI() {
        // Score
        scoreLabel = createLabel("SCORE: 0", position: CGPoint(x: 100, y: frame.maxY - 50))
        scoreLabel.horizontalAlignmentMode = .left
        
        // Lives with ship icons
        livesLabel = createLabel("LIVES: ♦♦♦", position: CGPoint(x: frame.maxX - 100, y: frame.maxY - 50))
        livesLabel.horizontalAlignmentMode = .right
        
        // Wave
        waveLabel = createLabel("WAVE 1", position: CGPoint(x: frame.midX, y: frame.maxY - 50))
        
        // Combo system
        comboLabel = createLabel("", position: CGPoint(x: frame.midX, y: frame.maxY - 100))
        comboLabel.fontColor = .yellow
        comboLabel.alpha = 0
        
        // Instructions
        instructionsLabel = createLabel("Left: Move | Right: Fire | SURVIVE THE VOID", 
                                      position: CGPoint(x: frame.midX, y: 50))
        instructionsLabel.fontSize = 16
        instructionsLabel.fontColor = .gray
        
        [scoreLabel, livesLabel, waveLabel, comboLabel, instructionsLabel].forEach {
            $0?.zPosition = 1000
            addChild($0!)
        }
    }
    
    private func createLabel(_ text: String, position: CGPoint) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "Helvetica-Bold"
        label.fontSize = 20
        label.fontColor = .cyan
        label.position = position
        return label
    }
    
    private func playIntroSequence() {
        // Zoom in effect on player ship
        playerShip.setScale(0.1)
        playerShip.alpha = 0
        
        let scaleUp = SKAction.scale(to: 1.0, duration: 2.0)
        let fadeIn = SKAction.fadeIn(withDuration: 2.0)
        let intro = SKAction.group([scaleUp, fadeIn])
        
        playerShip.run(intro) { [weak self] in
            self?.instructionsLabel.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 1.0),
                SKAction.wait(forDuration: 2.0),
                SKAction.fadeIn(withDuration: 1.0)
            ]))
        }
    }
    
    // MARK: - Game Loop
    
    override func update(_ currentTime: TimeInterval) {
        guard gameState == .playing else { return }
        
        updatePlayer(currentTime)
        updateEnemies(currentTime)
        updateProjectiles(currentTime)
        updatePowerUps(currentTime)
        updateBackground3D(currentTime)
        updateMothership(currentTime)
        spawnEnemies(currentTime)
        checkWaveProgression()
        updateUI()
        
        // Clean up off-screen objects
        cleanup()
    }
    
    private func updatePlayer(_ currentTime: TimeInterval) {
        playerShip.update(currentTime, leftStick: leftThumbstick)
        
        // Auto fire
        if rightThumbstick != CGPoint.zero && currentTime - lastAutoFire > 0.15 {
            firePlayerLaser()
            lastAutoFire = currentTime
        }
    }
    
    private func updateEnemies(_ currentTime: TimeInterval) {
        enemies.forEach { enemy in
            enemy.update(currentTime, playerPosition: playerShip.position)
        }
    }
    
    private func updateProjectiles(_ currentTime: TimeInterval) {
        lasers.forEach { laser in
            laser.update(currentTime)
        }
    }
    
    private func updatePowerUps(_ currentTime: TimeInterval) {
        powerUps.forEach { powerUp in
            powerUp.update(currentTime)
        }
    }
    
    private func updateBackground3D(_ currentTime: TimeInterval) {
        starField.update(currentTime, playerVelocity: playerShip.velocity)
        
        nebulae.forEach { nebula in
            nebula.update(currentTime, playerPosition: playerShip.position)
        }
        
        spaceDebris.forEach { debris in
            debris.update(currentTime)
        }
    }
    
    private func updateMothership(_ currentTime: TimeInterval) {
        mothership?.update(currentTime, playerPosition: playerShip.position)
    }
    
    private func spawnEnemies(_ currentTime: TimeInterval) {
        guard enemies.count < maxEnemies && 
              currentTime - lastEnemySpawn > enemySpawnRate &&
              !mothershipActive else { return }
        
        let enemy = EnemyShip3D(screenSize: size)
        enemies.insert(enemy)
        addChild(enemy)
        lastEnemySpawn = currentTime
        
        // Increase difficulty
        if enemies.count % 5 == 0 {
            enemySpawnRate = max(0.8, enemySpawnRate - 0.1)
        }
    }
    
    private func checkWaveProgression() {
        let newWave = (score / 1000) + 1
        if newWave > wave {
            wave = newWave
            waveLabel.text = "WAVE \(wave)"
            
            // Spawn mothership boss
            if wave % bossSpawnWave == 0 && !mothershipActive {
                spawnMothership()
            }
        }
    }
    
    private func spawnMothership() {
        mothershipActive = true
        gameState = .bossIntro
        
        // Clear enemies
        enemies.forEach { $0.removeFromParent() }
        enemies.removeAll()
        
        // Create mothership
        mothership = MothershipBoss(screenSize: size)
        mothership!.position = CGPoint(x: frame.midX, y: frame.maxY + 200)
        addChild(mothership!)
        
        // Boss intro sequence
        let moveIn = SKAction.move(to: CGPoint(x: frame.midX, y: frame.maxY - 150), duration: 3.0)
        mothership!.run(moveIn) { [weak self] in
            self?.gameState = .playing
        }
        
        // Warning UI
        let warningLabel = createLabel("⚠️ MOTHERSHIP DETECTED ⚠️", 
                                     position: CGPoint(x: frame.midX, y: frame.midY))
        warningLabel.fontSize = 30
        warningLabel.fontColor = .red
        addChild(warningLabel)
        
        warningLabel.run(SKAction.sequence([
            SKAction.repeat(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.fadeIn(withDuration: 0.3)
            ]), count: 5),
            SKAction.removeFromParent()
        ]))
    }
    
    // MARK: - Combat System
    
    private func firePlayerLaser() {
        let laser = Laser3D(
            from: playerShip.position,
            direction: rightThumbstick,
            type: .player
        )
        lasers.insert(laser)
        addChild(laser)
        
        // Spatial audio
        playSpatialSound("laser_fire", at: playerShip.position)
    }
    
    private func createExplosion(at position: CGPoint, type: ExplosionEffect3D.ExplosionType) {
        let explosion = ExplosionEffect3D(at: position, type: type)
        explosions.insert(explosion)
        addChild(explosion)
        
        // Screen shake for big explosions
        if type == .mothership {
            createScreenShake(intensity: 20)
        } else {
            createScreenShake(intensity: 5)
        }
        
        // Play simple sound effect
        run(SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false))
    }
    
    private func createScreenShake(intensity: CGFloat) {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: intensity, y: 0, duration: 0.05),
            SKAction.moveBy(x: -intensity * 2, y: 0, duration: 0.05),
            SKAction.moveBy(x: intensity, y: 0, duration: 0.05)
        ])
        run(shake)
    }
    
    // MARK: - Audio System
    
    private func playSpatialSound(_ soundName: String, at position: CGPoint) {
        // Simple sound playback
        // Note: Add sound files to project for this to work
        /*
        run(SKAction.playSoundFileNamed("\(soundName).wav", waitForCompletion: false))
        */
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches, event: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches, event: event)
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
    
    private func handleTouches(_ touches: Set<UITouch>, event: UIEvent?) {
        guard gameState == .playing else { return }
        
        for touch in touches {
            let location = touch.location(in: self)
            let previousLocation = touch.previousLocation(in: self)
            
            if location.x < frame.midX {
                // Left side - movement
                let deltaX = location.x - previousLocation.x
                let deltaY = location.y - previousLocation.y
                leftThumbstick = CGPoint(x: deltaX * 0.1, y: deltaY * 0.1)
            } else {
                // Right side - firing
                let deltaX = location.x - playerShip.position.x
                let deltaY = location.y - playerShip.position.y
                let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
                
                if distance > 0 {
                    rightThumbstick = CGPoint(
                        x: deltaX / distance,
                        y: deltaY / distance
                    )
                }
            }
        }
    }
    
    // MARK: - Collision Detection
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // Player vs Enemy
        if (bodyA.categoryBitMask == playerCategory && bodyB.categoryBitMask == enemyCategory) ||
           (bodyA.categoryBitMask == enemyCategory && bodyB.categoryBitMask == playerCategory) {
            handlePlayerEnemyCollision(bodyA, bodyB)
        }
        
        // Laser vs Enemy
        if (bodyA.categoryBitMask == laserCategory && bodyB.categoryBitMask == enemyCategory) ||
           (bodyA.categoryBitMask == enemyCategory && bodyB.categoryBitMask == laserCategory) {
            handleLaserEnemyCollision(bodyA, bodyB)
        }
        
        // Player vs PowerUp
        if (bodyA.categoryBitMask == playerCategory && bodyB.categoryBitMask == powerUpCategory) ||
           (bodyA.categoryBitMask == powerUpCategory && bodyB.categoryBitMask == playerCategory) {
            handlePlayerPowerUpCollision(bodyA, bodyB)
        }
        
        // Laser vs Mothership
        if (bodyA.categoryBitMask == laserCategory && bodyB.categoryBitMask == mothershipCategory) ||
           (bodyA.categoryBitMask == mothershipCategory && bodyB.categoryBitMask == laserCategory) {
            handleLaserMothershipCollision(bodyA, bodyB)
        }
    }
    
    private func handlePlayerEnemyCollision(_ bodyA: SKPhysicsBody, _ bodyB: SKPhysicsBody) {
        // Find enemy
        let enemy = (bodyA.categoryBitMask == enemyCategory) ? bodyA.node : bodyB.node
        
        if let enemyShip = enemy as? EnemyShip3D {
            enemies.remove(enemyShip)
            enemyShip.removeFromParent()
            
            createExplosion(at: enemyShip.position, type: ExplosionEffect3D.ExplosionType.enemy)
            
            // Damage player
            lives -= 1
            updateLivesDisplay()
            
            if lives <= 0 {
                gameOver()
            }
        }
    }
    
    private func handleLaserEnemyCollision(_ bodyA: SKPhysicsBody, _ bodyB: SKPhysicsBody) {
        let laser = (bodyA.categoryBitMask == laserCategory) ? bodyA.node : bodyB.node
        let enemy = (bodyA.categoryBitMask == enemyCategory) ? bodyA.node : bodyB.node
        
        if let laserNode = laser as? Laser3D,
           let enemyShip = enemy as? EnemyShip3D {
            
            lasers.remove(laserNode)
            laserNode.removeFromParent()
            
            enemies.remove(enemyShip)
            enemyShip.removeFromParent()
            
            createExplosion(at: enemyShip.position, type: ExplosionEffect3D.ExplosionType.enemy)
            
            // Score and combo
            combo += 1
            let points = 100 * combo
            score += points
            
            showComboText(points, at: enemyShip.position)
            
            // Chance for power-up
            if Int.random(in: 1...100) <= 25 {
                spawnPowerUp(at: enemyShip.position)
            }
        }
    }
    
    private func handlePlayerPowerUpCollision(_ bodyA: SKPhysicsBody, _ bodyB: SKPhysicsBody) {
        let powerUp = (bodyA.categoryBitMask == powerUpCategory) ? bodyA.node : bodyB.node
        
        if let powerUpNode = powerUp as? PowerUp3D {
            powerUps.remove(powerUpNode)
            powerUpNode.removeFromParent()
            
            applyPowerUp(powerUpNode.powerType)
            playSpatialSound("powerup_collect", at: powerUpNode.position)
        }
    }
    
    private func handleLaserMothershipCollision(_ bodyA: SKPhysicsBody, _ bodyB: SKPhysicsBody) {
        let laser = (bodyA.categoryBitMask == laserCategory) ? bodyA.node : bodyB.node
        
        if let laserNode = laser as? Laser3D,
           let mothershipNode = mothership {
            
            lasers.remove(laserNode)
            laserNode.removeFromParent()
            
            mothershipNode.takeDamage(10)
            
            if mothershipNode.isDestroyed {
                destroyMothership()
            }
        }
    }
    
    // MARK: - Power-up System
    
    private func spawnPowerUp(at position: CGPoint) {
        let powerUp = PowerUp3D(at: position)
        powerUps.insert(powerUp)
        addChild(powerUp)
    }
    
    private func applyPowerUp(_ type: PowerUpType) {
        switch type {
        case .extraLife:
            lives = min(5, lives + 1)
            updateLivesDisplay()
        case .rapidFire:
            playerShip.activateRapidFire()
        case .shield:
            playerShip.activateShield()
        case .tripleShot:
            playerShip.activateTripleShot()
        }
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        scoreLabel.text = "SCORE: \(score)"
        waveLabel.text = "WAVE \(wave)"
    }
    
    private func updateLivesDisplay() {
        livesLabel.text = "LIVES: \(String(repeating: "♦", count: lives))"
    }
    
    private func showComboText(_ points: Int, at position: CGPoint) {
        let comboText = SKLabelNode(text: "+\(points)")
        comboText.fontName = "Helvetica-Bold"
        comboText.fontSize = 16
        comboText.fontColor = .yellow
        comboText.position = position
        comboText.zPosition = 500
        addChild(comboText)
        
        comboText.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 50, duration: 1.0),
                SKAction.fadeOut(withDuration: 1.0)
            ]),
            SKAction.removeFromParent()
        ]))
        
        // Update combo label
        if combo > 1 {
            comboLabel.text = "COMBO x\(combo)"
            comboLabel.alpha = 1.0
            comboLabel.run(SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.fadeOut(withDuration: 0.5)
            ]))
        }
    }
    
    // MARK: - Game Over
    
    private func destroyMothership() {
        guard let mothership = mothership else { return }
        
        createExplosion(at: mothership.position, type: ExplosionEffect3D.ExplosionType.mothership)
        
        // Massive score bonus
        score += 5000
        showComboText(5000, at: mothership.position)
        
        mothership.removeFromParent()
        self.mothership = nil
        mothershipActive = false
        
        // Victory sequence
        let victoryLabel = createLabel("MOTHERSHIP DESTROYED!", position: CGPoint(x: frame.midX, y: frame.midY))
        victoryLabel.fontSize = 30
        victoryLabel.fontColor = .green
        addChild(victoryLabel)
        
        victoryLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.removeFromParent()
        ]))
    }
    
    private func gameOver() {
        gameState = .gameOver
        
        let gameOverScene = GameOverScene3D(size: size, finalScore: score, wave: wave)
        gameOverScene.scaleMode = scaleMode
        view?.presentScene(gameOverScene, transition: SKTransition.fade(withDuration: 1.0))
    }
    
    // MARK: - Enemy Laser Management
    
    func addEnemyLaser(_ laser: EnemyLaser3D) {
        lasers.insert(laser)
        addChild(laser)
    }
    
    // MARK: - Cleanup
    
    private func cleanup() {
        // Remove off-screen lasers
        lasers = lasers.filter { laser in
            if !frame.contains(laser.position) {
                laser.removeFromParent()
                return false
            }
            return true
        }
        
        // Remove finished explosions
        explosions = explosions.filter { explosion in
            if explosion.isFinished {
                explosion.removeFromParent()
                return false
            }
            return true
        }
        
        // Remove off-screen power-ups
        powerUps = powerUps.filter { powerUp in
            if !frame.contains(powerUp.position) {
                powerUp.removeFromParent()
                return false
            }
            return true
        }
    }
}

// MARK: - Supporting Enums

enum PowerUpType: CaseIterable {
    case extraLife, rapidFire, shield, tripleShot
}