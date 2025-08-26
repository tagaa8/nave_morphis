import SpriteKit

class GameOverScene: SKScene {
    
    private var finalScore: Int
    private var wave: Int
    
    private var titleLabel: SKLabelNode?
    private var scoreLabel: SKLabelNode?
    private var waveLabel: SKLabelNode?
    private var highScoreLabel: SKLabelNode?
    private var playAgainButton: SKLabelNode?
    private var mainMenuButton: SKLabelNode?
    
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
        setupBackground()
        setupUI()
        saveHighScore()
    }
    
    private func setupBackground() {
        // Campo de estrellas
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
        titleLabel = SKLabelNode(text: "GAME OVER")
        titleLabel?.fontName = "Helvetica-Bold"
        titleLabel?.fontSize = 48
        titleLabel?.fontColor = .red
        titleLabel?.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        titleLabel?.zPosition = 10
        
        scoreLabel = SKLabelNode(text: "Final Score: \(finalScore)")
        scoreLabel?.fontName = "Helvetica-Bold"
        scoreLabel?.fontSize = 24
        scoreLabel?.fontColor = .cyan
        scoreLabel?.position = CGPoint(x: frame.midX, y: frame.midY + 80)
        scoreLabel?.zPosition = 10
        
        waveLabel = SKLabelNode(text: "Wave Reached: \(wave)")
        waveLabel?.fontName = "Helvetica-Bold"
        waveLabel?.fontSize = 20
        waveLabel?.fontColor = .yellow
        waveLabel?.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        waveLabel?.zPosition = 10
        
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
        
        playAgainButton = createButton(text: "PLAY AGAIN", position: CGPoint(x: frame.midX, y: frame.midY - 50))
        mainMenuButton = createButton(text: "MAIN MENU", position: CGPoint(x: frame.midX, y: frame.midY - 100))
        
        if let titleLabel = titleLabel, let scoreLabel = scoreLabel, let waveLabel = waveLabel,
           let highScoreLabel = highScoreLabel, let playAgainButton = playAgainButton, let mainMenuButton = mainMenuButton {
            addChild(titleLabel)
            addChild(scoreLabel)
            addChild(waveLabel)
            addChild(highScoreLabel)
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
        
        return button
    }
    
    private func setupAnimations() {
        let titleFade = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 1.0),
            SKAction.fadeAlpha(to: 1.0, duration: 1.0)
        ])
        titleLabel?.run(SKAction.repeatForever(titleFade))
        
        let buttonPulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 1.5),
            SKAction.fadeAlpha(to: 1.0, duration: 1.5)
        ])
        playAgainButton?.run(SKAction.repeatForever(buttonPulse))
        mainMenuButton?.run(SKAction.repeatForever(buttonPulse))
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
        
        if let buttonName = touchedNode.name {
            handleButtonTap(buttonName)
        }
    }
    
    private func handleButtonTap(_ buttonName: String) {
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
        let transition = SKTransition.fade(withDuration: 0.5)
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        
        view?.presentScene(gameScene, transition: transition)
    }
    
    private func goToMainMenu() {
        let transition = SKTransition.fade(withDuration: 0.5)
        let mainMenuScene = MainMenuScene(size: size)
        mainMenuScene.scaleMode = scaleMode
        
        view?.presentScene(mainMenuScene, transition: transition)
    }
}