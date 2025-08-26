import SpriteKit

class GameOverScene: SKScene {
    
    private var won: Bool
    private var finalScore: Int
    private var wave: Int
    
    private var titleLabel: SKLabelNode?
    private var scoreLabel: SKLabelNode?
    private var waveLabel: SKLabelNode?
    private var highScoreLabel: SKLabelNode?
    private var playAgainButton: SKLabelNode?
    private var mainMenuButton: SKLabelNode?
    
    init(size: CGSize, won: Bool, finalScore: Int, wave: Int) {
        self.won = won
        self.finalScore = finalScore
        self.wave = wave
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupUI()
        saveHighScore()
    }
    
    private func setupBackground() {
        backgroundColor = .black
        
        let overlay = SKSpriteNode(color: .black.withAlphaComponent(0.7), size: size)
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        overlay.zPosition = -1
        addChild(overlay)
        
        for _ in 0..<50 {
            let star = SKSpriteNode(color: .white, size: CGSize(width: 2, height: 2))
            star.position = CGPoint(
                x: CGFloat.random(in: frame.minX...frame.maxX),
                y: CGFloat.random(in: frame.minY...frame.maxY)
            )
            star.alpha = CGFloat.random(in: 0.3...1.0)
            star.zPosition = -2
            addChild(star)
            
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 1...3)),
                SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 1...3))
            ])
            star.run(SKAction.repeatForever(twinkle))
        }
    }
    
    private func setupUI() {
        let titleText = won ? "VICTORY!" : "GAME OVER"
        let titleColor: UIColor = won ? .green : .red
        
        titleLabel = SKLabelNode(text: titleText)
        titleLabel?.fontName = "Helvetica-Bold"
        titleLabel?.fontSize = 48
        titleLabel?.fontColor = titleColor
        titleLabel?.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        titleLabel?.zPosition = 10
        
        if let titleLabel = titleLabel {
            addChild(titleLabel)
        }
        
        scoreLabel = SKLabelNode(text: "Final Score: \(finalScore)")
        scoreLabel?.fontName = "Helvetica-Bold"
        scoreLabel?.fontSize = 24
        scoreLabel?.fontColor = .cyan
        scoreLabel?.position = CGPoint(x: frame.midX, y: frame.midY + 80)
        scoreLabel?.zPosition = 10
        
        if let scoreLabel = scoreLabel {
            addChild(scoreLabel)
        }
        
        waveLabel = SKLabelNode(text: "Wave Reached: \(wave)")
        waveLabel?.fontName = "Helvetica-Bold"
        waveLabel?.fontSize = 20
        waveLabel?.fontColor = .yellow
        waveLabel?.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        waveLabel?.zPosition = 10
        
        if let waveLabel = waveLabel {
            addChild(waveLabel)
        }
        
        let highScore = getHighScore()
        let isNewHighScore = finalScore > highScore
        let highScoreText = isNewHighScore ? "NEW HIGH SCORE!" : "High Score: \(highScore)"
        let highScoreColor: UIColor = isNewHighScore ? .magenta : .white
        
        highScoreLabel = SKLabelNode(text: highScoreText)
        highScoreLabel?.fontName = "Helvetica-Bold"
        highScoreLabel?.fontSize = isNewHighScore ? 22 : 18
        highScoreLabel?.fontColor = highScoreColor
        highScoreLabel?.position = CGPoint(x: frame.midX, y: frame.midY + 10)
        highScoreLabel?.zPosition = 10
        
        if let highScoreLabel = highScoreLabel {
            addChild(highScoreLabel)
            
            if isNewHighScore {
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.2, duration: 0.5),
                    SKAction.scale(to: 1.0, duration: 0.5)
                ])
                highScoreLabel.run(SKAction.repeatForever(pulse))
            }
        }
        
        playAgainButton = createButton(text: "PLAY AGAIN", position: CGPoint(x: frame.midX, y: frame.midY - 50))
        mainMenuButton = createButton(text: "MAIN MENU", position: CGPoint(x: frame.midX, y: frame.midY - 100))
        
        if let playAgainButton = playAgainButton, let mainMenuButton = mainMenuButton {
            addChild(playAgainButton)
            addChild(mainMenuButton)
        }
        
        setupAnimations()
    }
    
    private func createButton(text: String, position: CGPoint) -> SKLabelNode {
        let button = SKLabelNode(text: text)
        button.fontName = "Helvetica-Bold"
        button.fontSize = 28
        button.fontColor = .white
        button.position = position
        button.zPosition = 10
        button.name = text.lowercased().replacingOccurrences(of: " ", with: "_")
        
        let background = SKShapeNode(rectOf: CGSize(width: 250, height: 45), cornerRadius: 10)
        background.fillColor = .darkGray.withAlphaComponent(0.3)
        background.strokeColor = .cyan
        background.lineWidth = 2
        background.zPosition = -1
        background.alpha = 0.8
        button.addChild(background)
        
        return button
    }
    
    private func setupAnimations() {
        if won {
            let celebrate = SKEmitterNode()
            celebrate.particleTexture = SKTexture(imageNamed: "spark")
            celebrate.particleBirthRate = 100
            celebrate.particleLifetime = 2.0
            celebrate.particleLifetimeRange = 1.0
            celebrate.particlePositionRange = CGVector(dx: size.width, dy: 50)
            celebrate.particleSpeed = 200
            celebrate.particleSpeedRange = 100
            celebrate.particleScale = 0.5
            celebrate.particleScaleRange = 0.3
            celebrate.particleColorRed = CGFloat.random(in: 0.5...1.0)
            celebrate.particleColorGreen = CGFloat.random(in: 0.5...1.0)
            celebrate.particleColorBlue = CGFloat.random(in: 0.5...1.0)
            celebrate.particleAlpha = 0.8
            celebrate.particleAlphaSpeed = -0.4
            celebrate.emissionAngle = CGFloat.pi / 2
            celebrate.emissionAngleRange = CGFloat.pi / 4
            celebrate.position = CGPoint(x: frame.midX, y: frame.maxY)
            celebrate.zPosition = 5
            
            addChild(celebrate)
            
            let stopCelebration = SKAction.sequence([
                SKAction.wait(forDuration: 5.0),
                SKAction.removeFromParent()
            ])
            celebrate.run(stopCelebration)
        }
        
        let titleAnimation = won ? createVictoryAnimation() : createGameOverAnimation()
        titleLabel?.run(titleAnimation)
    }
    
    private func createVictoryAnimation() -> SKAction {
        let glow = SKAction.sequence([
            SKAction.colorize(with: .green, colorBlendFactor: 1.0, duration: 0.5),
            SKAction.colorize(with: .yellow, colorBlendFactor: 1.0, duration: 0.5),
            SKAction.colorize(with: .cyan, colorBlendFactor: 1.0, duration: 0.5)
        ])
        
        let scale = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        
        return SKAction.repeatForever(SKAction.group([glow, scale]))
    }
    
    private func createGameOverAnimation() -> SKAction {
        let fade = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 1.0),
            SKAction.fadeAlpha(to: 1.0, duration: 1.0)
        ])
        
        return SKAction.repeatForever(fade)
    }
    
    private func saveHighScore() {
        let currentHighScore = getHighScore()
        if finalScore > currentHighScore {
            UserDefaults.standard.set(finalScore, forKey: "HighScore")
        }
    }
    
    private func getHighScore() -> Int {
        return UserDefaults.standard.integer(forKey: "HighScore")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if let buttonName = touchedNode.name ?? touchedNode.parent?.name {
            handleButtonTap(buttonName)
        }
    }
    
    private func handleButtonTap(_ buttonName: String) {
        SoundManager.shared.playSound(.menuSelect)
        HapticManager.shared.playSelection()
        
        let button = childNode(withName: buttonName)
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let flashAction = SKAction.sequence([
            SKAction.colorize(with: .cyan, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.colorize(with: .white, colorBlendFactor: 0.0, duration: 0.1)
        ])
        
        button?.run(SKAction.group([
            SKAction.sequence([scaleUp, scaleDown]),
            flashAction
        ]))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.executeButtonAction(buttonName)
        }
    }
    
    private func executeButtonAction(_ buttonName: String) {
        switch buttonName {
        case "play_again":
            playAgain()
        case "main_menu":
            goToMainMenu()
        default:
            break
        }
    }
    
    private func playAgain() {
        SoundManager.shared.playSound(.menuConfirm)
        
        let transition = SKTransition.fade(withDuration: 0.5)
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        
        view?.presentScene(gameScene, transition: transition)
    }
    
    private func goToMainMenu() {
        SoundManager.shared.playSound(.menuConfirm)
        
        let transition = SKTransition.fade(withDuration: 0.5)
        let mainMenuScene = MainMenuScene(size: size)
        mainMenuScene.scaleMode = scaleMode
        
        view?.presentScene(mainMenuScene, transition: transition)
    }
}