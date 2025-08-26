import SpriteKit

class MainMenuScene3D: SKScene {
    
    private var starField: StarField3D!
    private var nebulae: [NebulaLayer] = []
    private var titleLabel: SKLabelNode!
    private var playButton: SKLabelNode!
    private var versionLabel: SKLabelNode!
    private var spaceDebris: Set<SpaceDebris> = []
    
    // Animated background elements
    private var playerShipPreview: SKSpriteNode!
    private var enemyShipPreview: SKSpriteNode!
    private var mothershipPreview: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        setupBackground3D()
        setupUI()
        setupShipPreviews()
        startBackgroundAnimations()
    }
    
    private func setupBackground3D() {
        // Multi-layer starfield
        starField = StarField3D(size: size)
        addChild(starField)
        
        // Create nebula layers for depth
        createNebulae()
        
        // Add space debris
        createSpaceDebris()
    }
    
    private func createNebulae() {
        let nebulaConfigs = [
            (color: UIColor.purple, alpha: 0.08, depth: 1.0),
            (color: UIColor.cyan, alpha: 0.06, depth: 2.0),
            (color: UIColor.magenta, alpha: 0.04, depth: 3.0)
        ]
        
        for config in nebulaConfigs {
            let nebula = NebulaLayer(
                size: size,
                depth: config.depth,
                color: config.color,
                alpha: config.alpha
            )
            nebula.zPosition = -20 - config.depth * 5
            addChild(nebula)
            nebulae.append(nebula)
        }
    }
    
    private func createSpaceDebris() {
        for _ in 0..<20 {
            let debris = SpaceDebris(size: size)
            addChild(debris)
            spaceDebris.insert(debris)
        }
    }
    
    private func setupUI() {
        // Title with 3D effect
        titleLabel = SKLabelNode(text: "NAVE MORPHIS 3D")
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 56
        titleLabel.fontColor = .cyan
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 120)
        titleLabel.zPosition = 100
        
        // Add title glow effect
        let titleGlow = SKEffectNode()
        titleGlow.shouldRasterize = true
        titleGlow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10])
        
        let glowLabel = SKLabelNode(text: "NAVE MORPHIS 3D")
        glowLabel.fontName = "Helvetica-Bold"
        glowLabel.fontSize = 56
        glowLabel.fontColor = .cyan
        glowLabel.alpha = 0.8
        titleGlow.addChild(glowLabel)
        titleGlow.position = titleLabel.position
        titleGlow.zPosition = 99
        
        addChild(titleGlow)
        addChild(titleLabel)
        
        // Subtitle
        let subtitle = SKLabelNode(text: "ULTIMATE SPACE COMBAT EXPERIENCE")
        subtitle.fontName = "Helvetica"
        subtitle.fontSize = 18
        subtitle.fontColor = .white
        subtitle.alpha = 0.8
        subtitle.position = CGPoint(x: frame.midX, y: frame.midY + 70)
        subtitle.zPosition = 100
        addChild(subtitle)
        
        // Play button
        playButton = SKLabelNode(text: "▶ ENGAGE HYPERSPACE ◀")
        playButton.fontName = "Helvetica-Bold"
        playButton.fontSize = 32
        playButton.fontColor = .green
        playButton.position = CGPoint(x: frame.midX, y: frame.midY - 20)
        playButton.name = "play_button"
        playButton.zPosition = 100
        addChild(playButton)
        
        // Instructions
        let instructions = SKLabelNode(text: "Twin-Stick Controls | 3D Graphics | Epic Boss Battles")
        instructions.fontName = "Helvetica"
        instructions.fontSize = 16
        instructions.fontColor = .gray
        instructions.position = CGPoint(x: frame.midX, y: frame.midY - 80)
        instructions.zPosition = 100
        addChild(instructions)
        
        // Version info
        versionLabel = SKLabelNode(text: "v3.0 - ENHANCED EDITION")
        versionLabel.fontName = "Helvetica"
        versionLabel.fontSize = 14
        versionLabel.fontColor = .darkGray
        versionLabel.position = CGPoint(x: frame.midX, y: 50)
        versionLabel.zPosition = 100
        addChild(versionLabel)
        
        // Feature highlights
        let features = [
            "✦ Dynamic 3D Starfields",
            "✦ Intelligent Enemy AI",
            "✦ Destructible Mothership Boss",
            "✦ Advanced Particle Effects",
            "✦ Spatial Audio System"
        ]
        
        for (index, feature) in features.enumerated() {
            let featureLabel = SKLabelNode(text: feature)
            featureLabel.fontName = "Helvetica"
            featureLabel.fontSize = 14
            featureLabel.fontColor = .yellow
            featureLabel.alpha = 0.7
            featureLabel.horizontalAlignmentMode = .left
            featureLabel.position = CGPoint(
                x: frame.midX - 200,
                y: frame.midY - 150 - CGFloat(index * 25)
            )
            featureLabel.zPosition = 100
            addChild(featureLabel)
            
            // Animate features appearing
            featureLabel.alpha = 0
            let delay = Double(index) * 0.3
            let fadeIn = SKAction.fadeAlpha(to: 0.7, duration: 0.5)
            featureLabel.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                fadeIn
            ]))
        }
    }
    
    private func setupShipPreviews() {
        // Player ship preview (left side)
        playerShipPreview = SKSpriteNode(imageNamed: "player_ship")
        playerShipPreview.position = CGPoint(x: frame.midX - 300, y: frame.midY - 50)
        playerShipPreview.setScale(1.5)
        playerShipPreview.zPosition = 50
        addChild(playerShipPreview)
        
        // Add player ship glow
        let playerGlow = SKEffectNode()
        playerGlow.shouldRasterize = true
        playerGlow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 8])
        
        let playerGlowSprite = SKSpriteNode(imageNamed: "player_ship")
        playerGlowSprite.color = .cyan
        playerGlowSprite.colorBlendFactor = 1.0
        playerGlowSprite.alpha = 0.6
        playerGlowSprite.setScale(1.5)
        playerGlow.addChild(playerGlowSprite)
        playerGlow.position = playerShipPreview.position
        playerGlow.zPosition = 49
        addChild(playerGlow)
        
        // Enemy ship preview (right side)
        enemyShipPreview = SKSpriteNode(imageNamed: "enemy_ship")
        enemyShipPreview.position = CGPoint(x: frame.midX + 300, y: frame.midY - 50)
        enemyShipPreview.setScale(1.2)
        enemyShipPreview.zRotation = CGFloat.pi // Face opposite direction
        enemyShipPreview.zPosition = 50
        addChild(enemyShipPreview)
        
        // Add enemy ship glow
        let enemyGlow = SKEffectNode()
        enemyGlow.shouldRasterize = true
        enemyGlow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 8])
        
        let enemyGlowSprite = SKSpriteNode(imageNamed: "enemy_ship")
        enemyGlowSprite.color = .red
        enemyGlowSprite.colorBlendFactor = 1.0
        enemyGlowSprite.alpha = 0.6
        enemyGlowSprite.setScale(1.2)
        enemyGlowSprite.zRotation = CGFloat.pi
        enemyGlow.addChild(enemyGlowSprite)
        enemyGlow.position = enemyShipPreview.position
        enemyGlow.zPosition = 49
        addChild(enemyGlow)
        
        // Mothership preview (background)
        mothershipPreview = SKSpriteNode(imageNamed: "mothership_or_map")
        mothershipPreview.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        mothershipPreview.alpha = 0.3
        mothershipPreview.setScale(0.8)
        mothershipPreview.zPosition = 10
        addChild(mothershipPreview)
        
        // Add mothership glow
        let mothershipGlow = SKEffectNode()
        mothershipGlow.shouldRasterize = true
        mothershipGlow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 15])
        
        let mothershipGlowSprite = SKSpriteNode(imageNamed: "mothership_or_map")
        mothershipGlowSprite.color = .purple
        mothershipGlowSprite.colorBlendFactor = 0.8
        mothershipGlowSprite.alpha = 0.4
        mothershipGlowSprite.setScale(0.8)
        mothershipGlow.addChild(mothershipGlowSprite)
        mothershipGlow.position = mothershipPreview.position
        mothershipGlow.zPosition = 9
        addChild(mothershipGlow)
        
        // Ship labels
        let playerLabel = SKLabelNode(text: "YOUR SHIP")
        playerLabel.fontName = "Helvetica"
        playerLabel.fontSize = 16
        playerLabel.fontColor = .cyan
        playerLabel.position = CGPoint(x: playerShipPreview.position.x, y: playerShipPreview.position.y - 50)
        playerLabel.zPosition = 100
        addChild(playerLabel)
        
        let enemyLabel = SKLabelNode(text: "ENEMY FORCES")
        enemyLabel.fontName = "Helvetica"
        enemyLabel.fontSize = 16
        enemyLabel.fontColor = .red
        enemyLabel.position = CGPoint(x: enemyShipPreview.position.x, y: enemyShipPreview.position.y - 50)
        enemyLabel.zPosition = 100
        addChild(enemyLabel)
        
        let mothershipLabel = SKLabelNode(text: "MOTHERSHIP BOSS")
        mothershipLabel.fontName = "Helvetica"
        mothershipLabel.fontSize = 16
        mothershipLabel.fontColor = .purple
        mothershipLabel.alpha = 0.8
        mothershipLabel.position = CGPoint(x: mothershipPreview.position.x, y: mothershipPreview.position.y - 80)
        mothershipLabel.zPosition = 100
        addChild(mothershipLabel)
    }
    
    private func startBackgroundAnimations() {
        // Title animations
        let titleGlow = SKAction.sequence([
            SKAction.colorize(with: .cyan, colorBlendFactor: 1.0, duration: 2.0),
            SKAction.colorize(with: .magenta, colorBlendFactor: 1.0, duration: 2.0),
            SKAction.colorize(with: .yellow, colorBlendFactor: 1.0, duration: 2.0)
        ])
        titleLabel.run(SKAction.repeatForever(titleGlow))
        
        // Play button pulse
        let buttonPulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        playButton.run(SKAction.repeatForever(buttonPulse))
        
        let buttonGlow = SKAction.sequence([
            SKAction.colorize(with: .green, colorBlendFactor: 1.0, duration: 1.5),
            SKAction.colorize(with: .cyan, colorBlendFactor: 1.0, duration: 1.5)
        ])
        playButton.run(SKAction.repeatForever(buttonGlow))
        
        // Ship animations
        let playerFloat = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 20, duration: 2.0),
            SKAction.moveBy(x: 0, y: -20, duration: 2.0)
        ])
        playerShipPreview.run(SKAction.repeatForever(playerFloat))
        
        let enemyFloat = SKAction.sequence([
            SKAction.moveBy(x: 0, y: -15, duration: 2.5),
            SKAction.moveBy(x: 0, y: 15, duration: 2.5)
        ])
        enemyShipPreview.run(SKAction.repeatForever(enemyFloat))
        
        // Mothership slow rotation
        let mothershipRotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 20)
        mothershipPreview.run(SKAction.repeatForever(mothershipRotate))
        
        // Version label fade
        let versionFade = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 3.0),
            SKAction.fadeAlpha(to: 0.8, duration: 3.0)
        ])
        versionLabel.run(SKAction.repeatForever(versionFade))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Update background elements
        starField.update(currentTime, playerVelocity: CGVector.zero)
        
        nebulae.forEach { nebula in
            nebula.update(currentTime, playerPosition: CGPoint(x: frame.midX, y: frame.midY))
        }
        
        spaceDebris.forEach { debris in
            debris.update(currentTime)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "play_button" || touchedNode == playButton {
            startGame()
        } else {
            // Any touch starts the game for mobile-friendly experience
            startGame()
        }
    }
    
    private func startGame() {
        // Play button press effect
        playButton.run(SKAction.sequence([
            SKAction.scale(to: 0.9, duration: 0.1),
            SKAction.scale(to: 1.1, duration: 0.1)
        ]))
        
        // Screen flash transition
        let flash = SKSpriteNode(color: .white, size: frame.size)
        flash.position = CGPoint(x: frame.midX, y: frame.midY)
        flash.alpha = 0
        flash.zPosition = 1000
        addChild(flash)
        
        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.8, duration: 0.2),
            SKAction.fadeAlpha(to: 0, duration: 0.3)
        ])) { [weak self] in
            flash.removeFromParent()
            self?.transitionToGame()
        }
    }
    
    private func transitionToGame() {
        let transition = SKTransition.fade(withDuration: 1.0)
        let gameScene = GameScene3D(size: size)
        gameScene.scaleMode = scaleMode
        
        view?.presentScene(gameScene, transition: transition)
    }
}