import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var player: SKSpriteNode?
    private var enemies: [SKSpriteNode] = []
    private var lasers: [SKSpriteNode] = []
    private var powerUps: [SKSpriteNode] = []
    
    private var score: Int = 0
    private var wave: Int = 1
    private var lives: Int = 3
    private var lastUpdate: TimeInterval = 0
    
    private var hudLabel: SKLabelNode?
    private var waveLabel: SKLabelNode?
    private var livesLabel: SKLabelNode?
    
    private var leftThumbstick: CGPoint = CGPoint.zero
    private var rightThumbstick: CGPoint = CGPoint.zero
    
    private var lastEnemySpawn: TimeInterval = 0
    private var lastAutoFire: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector.zero
        backgroundColor = .black
        
        setupBackground()
        setupPlayer()
        setupHUD()
        spawnEnemies()
    }
    
    private func setupBackground() {
        // Campo de estrellas animado
        for _ in 0..<200 {
            let star = SKSpriteNode(color: .white, size: CGSize(width: 1, height: 1))
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.alpha = CGFloat.random(in: 0.3...0.8)
            addChild(star)
            
            // Movimiento de estrellas
            let moveDown = SKAction.moveBy(x: 0, y: -size.height - 100, duration: Double.random(in: 8...15))
            let reset = SKAction.moveBy(x: 0, y: size.height + 100, duration: 0)
            let sequence = SKAction.sequence([moveDown, reset])
            star.run(SKAction.repeatForever(sequence))
        }
        
        // Nebula de fondo
        let nebula = SKSpriteNode(color: .purple.withAlphaComponent(0.2), size: CGSize(width: size.width * 2, height: size.height))
        nebula.position = CGPoint(x: frame.midX, y: frame.midY)
        nebula.blendMode = .add
        addChild(nebula)
        
        let nebulaMove = SKAction.moveBy(x: -size.width * 2, y: 0, duration: 20)
        let nebulaReset = SKAction.moveBy(x: size.width * 4, y: 0, duration: 0)
        let nebulaSequence = SKAction.sequence([nebulaMove, nebulaReset])
        nebula.run(SKAction.repeatForever(nebulaSequence))
    }
    
    private func setupPlayer() {
        // Crear nave jugador (triángulo cyan)
        let playerTexture = createShipTexture(color: .cyan, isPlayer: true)
        player = SKSpriteNode(texture: playerTexture)
        player?.size = CGSize(width: 40, height: 60)
        player?.position = CGPoint(x: frame.midX, y: frame.minY + 150)
        
        // Física del jugador
        player?.physicsBody = SKPhysicsBody(rectangleOf: player!.size)
        player?.physicsBody?.categoryBitMask = 1 // Player
        player?.physicsBody?.contactTestBitMask = 6 // Enemy + EnemyLaser
        player?.physicsBody?.collisionBitMask = 0
        player?.physicsBody?.affectedByGravity = false
        
        if let player = player {
            addChild(player)
            
            // Efecto de brillo
            let glow = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 70))
            glow.alpha = 0.3
            glow.blendMode = .add
            glow.zPosition = -1
            player.addChild(glow)
        }
    }
    
    private func createShipTexture(color: UIColor, isPlayer: Bool) -> SKTexture {
        let size = CGSize(width: 40, height: 60)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            color.setFill()
            
            if isPlayer {
                // Triángulo apuntando hacia arriba (jugador)
                let path = UIBezierPath()
                path.move(to: CGPoint(x: size.width/2, y: size.height - 5))
                path.addLine(to: CGPoint(x: 5, y: 5))
                path.addLine(to: CGPoint(x: size.width/2, y: 15))
                path.addLine(to: CGPoint(x: size.width - 5, y: 5))
                path.close()
                path.fill()
            } else {
                // Triángulo apuntando hacia abajo (enemigo)
                let path = UIBezierPath()
                path.move(to: CGPoint(x: size.width/2, y: 5))
                path.addLine(to: CGPoint(x: 5, y: size.height - 5))
                path.addLine(to: CGPoint(x: size.width/2, y: size.height - 15))
                path.addLine(to: CGPoint(x: size.width - 5, y: size.height - 5))
                path.close()
                path.fill()
            }
        }
        
        return SKTexture(image: image)
    }
    
    private func setupHUD() {
        hudLabel = SKLabelNode(text: "Score: 0")
        hudLabel?.fontName = "Helvetica-Bold"
        hudLabel?.fontSize = 18
        hudLabel?.fontColor = .cyan
        hudLabel?.position = CGPoint(x: 80, y: frame.maxY - 40)
        hudLabel?.zPosition = 100
        
        waveLabel = SKLabelNode(text: "Wave: 1")
        waveLabel?.fontName = "Helvetica-Bold"
        waveLabel?.fontSize = 18
        waveLabel?.fontColor = .yellow
        waveLabel?.position = CGPoint(x: frame.midX, y: frame.maxY - 40)
        waveLabel?.zPosition = 100
        
        livesLabel = SKLabelNode(text: "Lives: 3")
        livesLabel?.fontName = "Helvetica-Bold"
        livesLabel?.fontSize = 18
        livesLabel?.fontColor = .red
        livesLabel?.position = CGPoint(x: frame.maxX - 80, y: frame.maxY - 40)
        livesLabel?.zPosition = 100
        
        if let hudLabel = hudLabel, let waveLabel = waveLabel, let livesLabel = livesLabel {
            addChild(hudLabel)
            addChild(waveLabel)
            addChild(livesLabel)
        }
        
        // Instrucciones
        let instructions = SKLabelNode(text: "Left: Move | Right: Fire")
        instructions.fontName = "Helvetica"
        instructions.fontSize = 14
        instructions.fontColor = .lightGray
        instructions.position = CGPoint(x: frame.midX, y: 30)
        instructions.zPosition = 100
        addChild(instructions)
    }
    
    private func spawnEnemies() {
        for _ in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...2)) {
                self.createEnemy()
            }
        }
    }
    
    private func createEnemy() {
        let enemyTexture = createShipTexture(color: .red, isPlayer: false)
        let enemy = SKSpriteNode(texture: enemyTexture)
        enemy.size = CGSize(width: 30, height: 40)
        
        // Posición aleatoria en la parte superior
        enemy.position = CGPoint(
            x: CGFloat.random(in: 50...(size.width - 50)),
            y: size.height + 50
        )
        
        // Física del enemigo
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = 2 // Enemy
        enemy.physicsBody?.contactTestBitMask = 5 // Player + PlayerLaser
        enemy.physicsBody?.collisionBitMask = 0
        enemy.physicsBody?.affectedByGravity = false
        
        // Efecto de brillo enemigo
        let glow = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 50))
        glow.alpha = 0.3
        glow.blendMode = .add
        glow.zPosition = -1
        enemy.addChild(glow)
        
        enemies.append(enemy)
        addChild(enemy)
        
        // Movimiento hacia el jugador
        if let player = player {
            let direction = CGVector(
                dx: player.position.x - enemy.position.x,
                dy: player.position.y - enemy.position.y
            )
            let length = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
            let normalizedDirection = CGVector(
                dx: direction.dx / length,
                dy: direction.dy / length
            )
            
            let moveAction = SKAction.move(by: CGVector(
                dx: normalizedDirection.dx * 800,
                dy: normalizedDirection.dy * 800
            ), duration: 4.0)
            
            let removeAction = SKAction.removeFromParent()
            enemy.run(SKAction.sequence([moveAction, removeAction]))
        }
    }
    
    private func fireLaser() {
        guard let player = player else { return }
        
        let laser = SKSpriteNode(color: .green, size: CGSize(width: 3, height: 15))
        laser.position = CGPoint(x: player.position.x, y: player.position.y + 30)
        
        // Física del láser
        laser.physicsBody = SKPhysicsBody(rectangleOf: laser.size)
        laser.physicsBody?.categoryBitMask = 4 // PlayerLaser
        laser.physicsBody?.contactTestBitMask = 2 // Enemy
        laser.physicsBody?.collisionBitMask = 0
        laser.physicsBody?.affectedByGravity = false
        laser.physicsBody?.usesPreciseCollisionDetection = true
        
        // Efecto de brillo del láser
        let glow = SKSpriteNode(color: .green, size: CGSize(width: 8, height: 20))
        glow.alpha = 0.5
        glow.blendMode = .add
        glow.zPosition = -1
        laser.addChild(glow)
        
        lasers.append(laser)
        addChild(laser)
        
        // Movimiento del láser
        let moveUp = SKAction.moveBy(x: 0, y: 700, duration: 1.0)
        let remove = SKAction.removeFromParent()
        laser.run(SKAction.sequence([moveUp, remove]))
        
        // Crear efecto de disparo en el jugador
        createMuzzleFlash(at: player.position)
    }
    
    private func createMuzzleFlash(at position: CGPoint) {
        let flash = SKSpriteNode(color: .white, size: CGSize(width: 15, height: 15))
        flash.position = CGPoint(x: position.x, y: position.y + 35)
        flash.alpha = 0.8
        flash.blendMode = .add
        addChild(flash)
        
        let scaleUp = SKAction.scale(to: 0, duration: 0.1)
        let remove = SKAction.removeFromParent()
        flash.run(SKAction.sequence([scaleUp, remove]))
    }
    
    private func createExplosion(at position: CGPoint, color: UIColor = .orange) {
        // Explosión principal
        let explosion = SKSpriteNode(color: color, size: CGSize(width: 60, height: 60))
        explosion.position = position
        explosion.alpha = 0.8
        explosion.blendMode = .add
        addChild(explosion)
        
        let scaleUp = SKAction.scale(to: 2.0, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        
        explosion.run(SKAction.sequence([
            SKAction.group([scaleUp, fadeOut]),
            remove
        ]))
        
        // Partículas de explosión
        for _ in 0..<8 {
            let spark = SKSpriteNode(color: .yellow, size: CGSize(width: 4, height: 4))
            spark.position = position
            spark.alpha = 1.0
            addChild(spark)
            
            let randomDirection = CGVector(
                dx: CGFloat.random(in: -100...100),
                dy: CGFloat.random(in: -100...100)
            )
            
            let moveAction = SKAction.move(by: randomDirection, duration: 0.5)
            let fadeAction = SKAction.fadeOut(withDuration: 0.5)
            let removeAction = SKAction.removeFromParent()
            
            spark.run(SKAction.sequence([
                SKAction.group([moveAction, fadeAction]),
                removeAction
            ]))
        }
    }
    
    private func createPowerUp(at position: CGPoint) {
        let powerUp = SKSpriteNode(color: .magenta, size: CGSize(width: 20, height: 20))
        powerUp.position = position
        
        // Física del power-up
        powerUp.physicsBody = SKPhysicsBody(rectangleOf: powerUp.size)
        powerUp.physicsBody?.categoryBitMask = 8 // PowerUp
        powerUp.physicsBody?.contactTestBitMask = 1 // Player
        powerUp.physicsBody?.collisionBitMask = 0
        powerUp.physicsBody?.affectedByGravity = false
        
        // Efecto de brillo
        let glow = SKSpriteNode(color: .magenta, size: CGSize(width: 30, height: 30))
        glow.alpha = 0.4
        glow.blendMode = .add
        glow.zPosition = -1
        powerUp.addChild(glow)
        
        powerUps.append(powerUp)
        addChild(powerUp)
        
        // Animación de flotación
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 10, duration: 1.0),
            SKAction.moveBy(x: 0, y: -10, duration: 1.0)
        ])
        powerUp.run(SKAction.repeatForever(float))
        
        // Rotación
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 2.0)
        powerUp.run(SKAction.repeatForever(rotate))
        
        // Auto-destrucción después de 10 segundos
        let wait = SKAction.wait(forDuration: 10.0)
        let fadeAndRemove = SKAction.sequence([
            SKAction.fadeOut(withDuration: 1.0),
            SKAction.removeFromParent()
        ])
        powerUp.run(SKAction.sequence([wait, fadeAndRemove]))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdate == 0 {
            lastUpdate = currentTime
            return
        }
        
        let deltaTime = currentTime - lastUpdate
        lastUpdate = currentTime
        
        // Limpiar arrays
        enemies = enemies.filter { $0.parent != nil }
        lasers = lasers.filter { $0.parent != nil }
        powerUps = powerUps.filter { $0.parent != nil }
        
        // Spawn enemigos
        if currentTime - lastEnemySpawn > 2.0 && enemies.count < 5 {
            createEnemy()
            lastEnemySpawn = currentTime
        }
        
        // Auto-fire si hay input en el lado derecho
        if rightThumbstick != CGPoint.zero && currentTime - lastAutoFire > 0.2 {
            fireLaser()
            lastAutoFire = currentTime
        }
        
        // Mover jugador basado en thumbstick izquierdo
        if leftThumbstick != CGPoint.zero, let player = player {
            let speed: CGFloat = 300
            let moveX = leftThumbstick.x * speed * CGFloat(deltaTime)
            let moveY = leftThumbstick.y * speed * CGFloat(deltaTime)
            
            let newX = max(20, min(frame.maxX - 20, player.position.x + moveX))
            let newY = max(20, min(frame.maxY - 60, player.position.y + moveY))
            
            player.position = CGPoint(x: newX, y: newY)
        }
        
        // Actualizar HUD
        updateHUD()
    }
    
    private func updateHUD() {
        hudLabel?.text = "Score: \(score)"
        waveLabel?.text = "Wave: \(wave)"
        livesLabel?.text = "Lives: \(lives)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
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
    
    private func handleTouches(_ touches: Set<UITouch>) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if location.x < frame.midX {
                // Lado izquierdo - movimiento
                let centerLeft = CGPoint(x: frame.width * 0.25, y: frame.height * 0.3)
                let deltaX = (location.x - centerLeft.x) / 100
                let deltaY = (location.y - centerLeft.y) / 100
                
                leftThumbstick = CGPoint(
                    x: max(-1, min(1, deltaX)),
                    y: max(-1, min(1, deltaY))
                )
            } else {
                // Lado derecho - disparo
                let centerRight = CGPoint(x: frame.width * 0.75, y: frame.height * 0.3)
                let deltaX = location.x - centerRight.x
                let deltaY = location.y - centerRight.y
                
                if abs(deltaX) > 20 || abs(deltaY) > 20 {
                    rightThumbstick = CGPoint(x: deltaX, y: deltaY)
                } else {
                    rightThumbstick = CGPoint(x: 1, y: 1) // Disparo simple
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // Láser del jugador golpea enemigo
        if (bodyA.categoryBitMask == 4 && bodyB.categoryBitMask == 2) ||
           (bodyA.categoryBitMask == 2 && bodyB.categoryBitMask == 4) {
            
            let enemyNode = bodyA.categoryBitMask == 2 ? bodyA.node : bodyB.node
            let laserNode = bodyA.categoryBitMask == 4 ? bodyA.node : bodyB.node
            
            if let enemy = enemyNode, let laser = laserNode {
                createExplosion(at: enemy.position, color: .red)
                
                // 30% de posibilidad de crear power-up
                if Float.random(in: 0...1) < 0.3 {
                    createPowerUp(at: enemy.position)
                }
                
                enemy.removeFromParent()
                laser.removeFromParent()
                
                score += 100
                
                // Incrementar oleada cada 10 enemigos destruidos
                if score % 1000 == 0 {
                    wave += 1
                }
            }
        }
        
        // Jugador golpea enemigo
        else if (bodyA.categoryBitMask == 1 && bodyB.categoryBitMask == 2) ||
                (bodyA.categoryBitMask == 2 && bodyB.categoryBitMask == 1) {
            
            let playerNode = bodyA.categoryBitMask == 1 ? bodyA.node : bodyB.node
            let enemyNode = bodyA.categoryBitMask == 2 ? bodyA.node : bodyB.node
            
            if let player = playerNode, let enemy = enemyNode {
                createExplosion(at: player.position, color: .cyan)
                createExplosion(at: enemy.position, color: .red)
                
                enemy.removeFromParent()
                
                lives -= 1
                
                if lives <= 0 {
                    gameOver()
                } else {
                    // Respawn del jugador con invulnerabilidad temporal
                    player.alpha = 0.5
                    player.position = CGPoint(x: frame.midX, y: frame.minY + 150)
                    
                    let blink = SKAction.sequence([
                        SKAction.fadeAlpha(to: 0.2, duration: 0.2),
                        SKAction.fadeAlpha(to: 0.8, duration: 0.2)
                    ])
                    let blinkSequence = SKAction.repeat(blink, count: 5)
                    let restore = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
                    
                    player.run(SKAction.sequence([blinkSequence, restore]))
                }
            }
        }
        
        // Jugador recoge power-up
        else if (bodyA.categoryBitMask == 1 && bodyB.categoryBitMask == 8) ||
                (bodyA.categoryBitMask == 8 && bodyB.categoryBitMask == 1) {
            
            let powerUpNode = bodyA.categoryBitMask == 8 ? bodyA.node : bodyB.node
            
            if let powerUp = powerUpNode {
                createExplosion(at: powerUp.position, color: .magenta)
                powerUp.removeFromParent()
                
                // Efectos del power-up
                score += 50
                if lives < 5 { // Máximo 5 vidas
                    lives += 1
                }
                
                // Efecto visual en el jugador
                player?.run(SKAction.sequence([
                    SKAction.colorize(with: .magenta, colorBlendFactor: 0.5, duration: 0.2),
                    SKAction.colorize(with: .cyan, colorBlendFactor: 0.0, duration: 0.2)
                ]))
            }
        }
    }
    
    private func gameOver() {
        let transition = SKTransition.fade(withDuration: 1.0)
        let gameOverScene = GameOverScene(size: size, finalScore: score, wave: wave)
        gameOverScene.scaleMode = scaleMode
        
        view?.presentScene(gameOverScene, transition: transition)
    }
}