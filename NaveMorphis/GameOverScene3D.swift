import SpriteKit

class GameOverScene3D: SKScene {
    
    private var finalScore: Int
    private var wave: Int
    
    private var starField: StarField3D!
    private var nebulae: [NebulaLayer] = []
    private var explosionEffects: [ExplosionEffect3D] = []
    
    // UI Elements
    private var titleLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var waveLabel: SKLabelNode!
    private var highScoreLabel: SKLabelNode!
    private var statsContainer: SKNode!
    private var playAgainButton: SKLabelNode!
    private var mainMenuButton: SKLabelNode!
    
    init(size: CGSize, finalScore: Int, wave: Int) {
        self.finalScore = finalScore
        self.wave = wave
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        setupBackground3D()
        setupExplosionEffects()
        saveHighScore()
        setupUI()
        startAnimations()
    }
    
    private func setupBackground3D() {
        // Dimmed starfield for dramatic effect
        starField = StarField3D(size: size)
        starField.alpha = 0.6
        addChild(starField)
        
        // Red-tinted nebulae for "aftermath" feeling
        let nebulaConfigs = [
            (color: UIColor.red, alpha: 0.12, depth: 1.0),
            (color: UIColor.orange, alpha: 0.08, depth: 2.0),
            (color: UIColor.purple, alpha: 0.06, depth: 3.0)
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
    
    private func setupExplosionEffects() {
        // Create random explosion effects for atmosphere
        for _ in 0..<5 {
            let delay = Double.random(in: 0...3)
            run(SKAction.wait(forDuration: delay)) { [weak self] in
                guard let self = self else { return }
                
                let position = CGPoint(
                    x: CGFloat.random(in: 0...self.size.width),
                    y: CGFloat.random(in: 0...self.size.height)
                )
                
                let explosion = ExplosionEffect3D(at: position, type: .enemy)
                explosion.alpha = 0.3
                self.addChild(explosion)
                self.explosionEffects.append(explosion)
            }
        }
    }
    
    private func setupUI() {
        // Main title
        titleLabel = SKLabelNode(text: "MISSION TERMINATED")
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 48
        titleLabel.fontColor = .red
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        titleLabel.zPosition = 100
        
        // Add title glow
        let titleGlow = SKEffectNode()
        titleGlow.shouldRasterize = true
        titleGlow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10])
        
        let glowLabel = SKLabelNode(text: "MISSION TERMINATED")
        glowLabel.fontName = "Helvetica-Bold"
        glowLabel.fontSize = 48
        glowLabel.fontColor = .red
        glowLabel.alpha = 0.6
        titleGlow.addChild(glowLabel)
        titleGlow.position = titleLabel.position
        titleGlow.zPosition = 99
        
        addChild(titleGlow)
        addChild(titleLabel)
        
        // Stats container
        statsContainer = SKNode()
        statsContainer.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        statsContainer.zPosition = 100
        addChild(statsContainer)
        
        // Score
        scoreLabel = createStatsLabel("FINAL SCORE", value: "\\(finalScore)", yOffset: 50)
        
        // Wave
        waveLabel = createStatsLabel("WAVES SURVIVED", value: "\\(wave)", yOffset: 0)
        
        // High Score
        let highScore = getHighScore()
        let isNewHighScore = finalScore > highScore
        
        if isNewHighScore {
            highScoreLabel = createStatsLabel("★ NEW RECORD ★", value: "\\(finalScore)", yOffset: -50)
            highScoreLabel.fontColor = .gold
            
            // Add celebration effect
            createCelebrationEffect()
        } else {
            highScoreLabel = createStatsLabel("BEST SCORE", value: "\\(highScore)", yOffset: -50)
            highScoreLabel.fontColor = .yellow
        }
        
        // Performance rating
        let rating = getPerformanceRating()
        let ratingLabel = createStatsLabel("PERFORMANCE", value: rating.text, yOffset: -100)
        ratingLabel.fontColor = rating.color
        
        // Buttons
        playAgainButton = createButton("▶ RETRY MISSION", position: CGPoint(x: frame.midX - 100, y: frame.midY - 180))
        mainMenuButton = createButton("◀ MAIN MENU", position: CGPoint(x: frame.midX + 100, y: frame.midY - 180))
        
        addChild(playAgainButton)
        addChild(mainMenuButton)
        
        // Additional stats
        createDetailedStats()
    }
    
    private func createStatsLabel(_ title: String, value: String, yOffset: CGFloat) -> SKLabelNode {
        // Title
        let titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 20
        titleLabel.fontColor = .lightGray
        titleLabel.position = CGPoint(x: 0, y: yOffset + 15)
        statsContainer.addChild(titleLabel)
        
        // Value
        let valueLabel = SKLabelNode(text: value)
        valueLabel.fontName = "Helvetica-Bold"
        valueLabel.fontSize = 32
        valueLabel.fontColor = .white
        valueLabel.position = CGPoint(x: 0, y: yOffset - 10)
        statsContainer.addChild(valueLabel)
        
        return valueLabel
    }
    
    private func createButton(_ text: String, position: CGPoint) -> SKLabelNode {
        let button = SKLabelNode(text: text)
        button.fontName = "Helvetica-Bold"
        button.fontSize = 24
        button.fontColor = .cyan
        button.position = position
        button.zPosition = 100
        button.name = text.lowercased().replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "▶", with: "").replacingOccurrences(of: "◀", with: "")
        
        // Add button glow
        let glow = SKEffectNode()
        glow.shouldRasterize = true
        glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 5])
        
        let glowLabel = SKLabelNode(text: text)
        glowLabel.fontName = "Helvetica-Bold"
        glowLabel.fontSize = 24
        glowLabel.fontColor = .cyan
        glowLabel.alpha = 0.5
        glow.addChild(glowLabel)
        glow.position = position
        glow.zPosition = 99
        
        addChild(glow)
        
        return button
    }
    
    private func createDetailedStats() {
        let detailsContainer = SKNode()
        detailsContainer.position = CGPoint(x: frame.midX, y: frame.midY - 300)
        detailsContainer.zPosition = 50
        addChild(detailsContainer)
        
        // Calculate additional stats
        let avgPointsPerWave = wave > 0 ? finalScore / wave : 0
        let survivalTime = wave * 30 // Approximate seconds per wave
        
        let details = [
            "Points per Wave: \\(avgPointsPerWave)",
            "Estimated Survival: \\(survivalTime)s",
            "Enemies Defeated: ~\\(finalScore / 100)",
            "Accuracy Rating: \\(getAccuracyRating())%"
        ]
        
        for (index, detail) in details.enumerated() {
            let detailLabel = SKLabelNode(text: detail)
            detailLabel.fontName = "Helvetica"
            detailLabel.fontSize = 14
            detailLabel.fontColor = .darkGray
            detailLabel.position = CGPoint(x: 0, y: -CGFloat(index * 20))
            detailsContainer.addChild(detailLabel)
            
            // Animate details appearing
            detailLabel.alpha = 0
            let delay = Double(index) * 0.2 + 2.0
            detailLabel.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.fadeIn(withDuration: 0.5)
            ]))
        }
    }
    
    private func getPerformanceRating() -> (text: String, color: UIColor) {
        switch wave {
        case 0...2:
            return ("RECRUIT", .red)
        case 3...5:
            return ("SOLDIER", .orange)
        case 6...10:
            return ("VETERAN", .yellow)
        case 11...15:
            return ("ELITE", .green)
        case 16...20:
            return ("COMMANDER", .cyan)
        default:
            return ("LEGEND", .magenta)
        }
    }
    
    private func getAccuracyRating() -> Int {
        // Simulate accuracy based on performance
        let baseAccuracy = min(85, 30 + (wave * 3))
        return Int.random(in: max(20, baseAccuracy - 10)...min(95, baseAccuracy + 10))
    }
    
    private func createCelebrationEffect() {
        // Confetti effect for new high score
        for _ in 0..<3 {
            let delay = Double.random(in: 0...2)
            run(SKAction.wait(forDuration: delay)) { [weak self] in
                guard let self = self else { return }
                
                let confetti = SKEmitterNode()
                confetti.particleTexture = SKTexture(imageNamed: "spark")
                confetti.position = CGPoint(x: self.frame.midX, y: self.frame.maxY + 50)
                confetti.particleLifetime = 3.0
                confetti.particleBirthRate = 50
                confetti.numParticlesToEmit = 100
                confetti.particlePositionRange = CGVector(dx: self.frame.width, dy: 50)
                confetti.particleSpeed = 200
                confetti.particleSpeedRange = 150
                confetti.emissionAngle = -CGFloat.pi/2
                confetti.emissionAngleRange = CGFloat.pi/3
                confetti.particleColor = [.yellow, .magenta, .cyan, .green].randomElement()!
                confetti.particleColorBlendFactor = 0.8
                confetti.particleAlpha = 0.8
                confetti.particleAlphaSpeed = -0.3
                confetti.particleScale = 0.3
                confetti.particleScaleSpeed = -0.1
                confetti.zPosition = 200
                
                self.addChild(confetti)
                
                confetti.run(SKAction.sequence([
                    SKAction.wait(forDuration: 4.0),
                    SKAction.removeFromParent()
                ]))
            }
        }
        
        // Screen flash
        let flash = SKSpriteNode(color: .gold, size: frame.size)
        flash.position = CGPoint(x: frame.midX, y: frame.midY)
        flash.alpha = 0
        flash.zPosition = 150
        addChild(flash)
        
        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
            SKAction.fadeAlpha(to: 0, duration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
    
    private func startAnimations() {
        // Title dramatic entrance
        titleLabel.alpha = 0
        titleLabel.setScale(0.1)
        titleLabel.run(SKAction.group([
            SKAction.fadeIn(withDuration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ]))
        
        // Title flickering effect
        titleLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.7, duration: 0.8),
                SKAction.fadeAlpha(to: 1.0, duration: 0.8)
            ]))
        ]))
        
        // Stats container slide in
        statsContainer.position.y -= 100
        statsContainer.alpha = 0
        statsContainer.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.8),
            SKAction.group([
                SKAction.moveBy(x: 0, y: 100, duration: 1.0),
                SKAction.fadeIn(withDuration: 1.0)
            ])
        ]))
        
        // Buttons pulse
        let buttonPulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        
        playAgainButton.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.repeatForever(buttonPulse)
        ]))
        
        mainMenuButton.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.2),
            SKAction.repeatForever(buttonPulse)
        ]))
        
        // Button color cycling
        let colorCycle = SKAction.sequence([
            SKAction.colorize(with: .cyan, colorBlendFactor: 1.0, duration: 1.5),
            SKAction.colorize(with: .green, colorBlendFactor: 1.0, duration: 1.5)
        ])
        
        playAgainButton.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.repeatForever(colorCycle)
        ]))
        
        mainMenuButton.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.2),
            SKAction.repeatForever(colorCycle)
        ]))
    }
    
    private func saveHighScore() {
        let currentHighScore = getHighScore()
        if finalScore > currentHighScore {
            UserDefaults.standard.set(finalScore, forKey: "HighScore")
            UserDefaults.standard.synchronize()
        }
    }
    
    private func getHighScore() -> Int {
        return UserDefaults.standard.integer(forKey: "HighScore")
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Update background
        starField.update(currentTime, playerVelocity: CGVector.zero)
        
        nebulae.forEach { nebula in
            nebula.update(currentTime, playerPosition: CGPoint(x: frame.midX, y: frame.midY))
        }
        
        // Clean up finished explosions
        explosionEffects.removeAll { explosion in
            if explosion.isFinished {
                explosion.removeFromParent()
                return true
            }
            return false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if let buttonName = touchedNode.name {
            handleButtonTap(buttonName)
        }
    }
    
    private func handleButtonTap(_ buttonName: String) {
        switch buttonName {
        case "retry_mission":
            playAgain()
        case "main_menu":
            goToMainMenu()
        default:
            break
        }
    }
    
    private func playAgain() {
        // Button press effect
        playAgainButton.run(SKAction.sequence([
            SKAction.scale(to: 0.9, duration: 0.1),
            SKAction.scale(to: 1.1, duration: 0.1)
        ]))
        
        // Transition to game
        let transition = SKTransition.fade(withDuration: 0.8)
        let gameScene = GameScene3D(size: size)
        gameScene.scaleMode = scaleMode
        
        view?.presentScene(gameScene, transition: transition)
    }
    
    private func goToMainMenu() {
        // Button press effect
        mainMenuButton.run(SKAction.sequence([
            SKAction.scale(to: 0.9, duration: 0.1),
            SKAction.scale(to: 1.1, duration: 0.1)
        ]))
        
        // Transition to main menu
        let transition = SKTransition.fade(withDuration: 0.8)
        let mainMenuScene = MainMenuScene3D(size: size)
        mainMenuScene.scaleMode = scaleMode
        
        view?.presentScene(mainMenuScene, transition: transition)
    }
}

// MARK: - Extensions

extension UIColor {
    static var gold: UIColor {
        return UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
    }
}