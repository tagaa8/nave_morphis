import SpriteKit

class GameOverArena: SKScene {
    
    private let finalScore: Int
    private let finalWave: Int
    
    init(size: CGSize, finalScore: Int, wave: Int) {
        self.finalScore = finalScore
        self.finalWave = wave
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupUI()
        setupControls()
    }
    
    private func setupBackground() {
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0)
        
        // Dimmed arena background
        let arenaBackground = SKSpriteNode(imageNamed: "mothership_or_map")
        arenaBackground.size = CGSize(width: size.width * 0.9, height: size.height * 0.85)
        arenaBackground.position = CGPoint(x: frame.midX, y: frame.midY)
        arenaBackground.zPosition = -10
        arenaBackground.alpha = 0.1
        addChild(arenaBackground)
        
        // Add floating debris particles
        for _ in 0..<15 {
            let debris = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            debris.fillColor = .gray
            debris.strokeColor = .clear
            debris.alpha = 0.3
            debris.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            debris.zPosition = -5
            addChild(debris)
            
            // Slow floating animation
            let moveX = SKAction.moveBy(x: CGFloat.random(in: -30...30), y: 0, duration: Double.random(in: 8...12))
            let moveY = SKAction.moveBy(x: 0, y: CGFloat.random(in: -30...30), duration: Double.random(in: 8...12))
            let moveBack = SKAction.move(to: debris.position, duration: Double.random(in: 8...12))
            let sequence = SKAction.sequence([moveX, moveY, moveBack])
            debris.run(SKAction.repeatForever(sequence))
        }
    }
    
    private func setupUI() {
        // Game Over title
        let gameOverLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 64
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        gameOverLabel.zPosition = 10
        addChild(gameOverLabel)
        
        // Subtitle
        let subtitleLabel = SKLabelNode(fontNamed: "Helvetica")
        subtitleLabel.text = "Your ship has been destroyed"
        subtitleLabel.fontSize = 24
        subtitleLabel.fontColor = .white
        subtitleLabel.alpha = 0.8
        subtitleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        subtitleLabel.zPosition = 10
        addChild(subtitleLabel)
        
        // Final Score
        let scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabel.text = "FINAL SCORE"
        scoreLabel.fontSize = 32
        scoreLabel.fontColor = .cyan
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY + 20)
        scoreLabel.zPosition = 10
        addChild(scoreLabel)
        
        let scoreValueLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreValueLabel.text = "\(finalScore)"
        scoreValueLabel.fontSize = 48
        scoreValueLabel.fontColor = .yellow
        scoreValueLabel.position = CGPoint(x: frame.midX, y: frame.midY - 30)
        scoreValueLabel.zPosition = 10
        addChild(scoreValueLabel)
        
        // Wave reached
        let waveLabel = SKLabelNode(fontNamed: "Helvetica")
        waveLabel.text = "Waves Survived: \(finalWave)"
        waveLabel.fontSize = 28
        waveLabel.fontColor = .white
        waveLabel.position = CGPoint(x: frame.midX, y: frame.midY - 80)
        waveLabel.zPosition = 10
        addChild(waveLabel)
        
        // Performance rating
        let rating = getPerformanceRating()
        let ratingLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        ratingLabel.text = rating
        ratingLabel.fontSize = 32
        ratingLabel.fontColor = getRatingColor(rating)
        ratingLabel.position = CGPoint(x: frame.midX, y: frame.midY - 130)
        ratingLabel.zPosition = 10
        addChild(ratingLabel)
        
        // Animate labels
        animateLabels([gameOverLabel, subtitleLabel, scoreLabel, scoreValueLabel, waveLabel, ratingLabel])
    }
    
    private func setupControls() {
        // Play Again button
        let playAgainButton = createButton(text: "PLAY AGAIN", position: CGPoint(x: frame.midX, y: frame.midY - 200))
        playAgainButton.name = "playAgain"
        addChild(playAgainButton)
        
        // Main Menu button
        let mainMenuButton = createButton(text: "MAIN MENU", position: CGPoint(x: frame.midX, y: frame.midY - 260))
        mainMenuButton.name = "mainMenu"
        addChild(mainMenuButton)
        
        // Instructions
        let instructionLabel = SKLabelNode(fontNamed: "Helvetica")
        instructionLabel.text = "Tap to continue"
        instructionLabel.fontSize = 18
        instructionLabel.fontColor = .white
        instructionLabel.alpha = 0.6
        instructionLabel.position = CGPoint(x: frame.midX, y: 50)
        instructionLabel.zPosition = 10
        addChild(instructionLabel)
        
        // Blinking animation for instruction
        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 1.0),
            SKAction.fadeAlpha(to: 0.6, duration: 1.0)
        ])
        instructionLabel.run(SKAction.repeatForever(blink))
    }
    
    private func createButton(text: String, position: CGPoint) -> SKNode {
        let button = SKNode()
        button.position = position
        
        // Button background
        let background = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 10)
        background.fillColor = .clear
        background.strokeColor = .cyan
        background.lineWidth = 2
        background.alpha = 0.8
        button.addChild(background)
        
        // Button text
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = text
        label.fontSize = 20
        label.fontColor = .cyan
        label.verticalAlignmentMode = .center
        button.addChild(label)
        
        return button
    }
    
    private func getPerformanceRating() -> String {
        let scorePerWave = finalWave > 0 ? finalScore / finalWave : finalScore
        
        switch scorePerWave {
        case 0..<200:
            return "ROOKIE PILOT"
        case 200..<500:
            return "CADET"
        case 500..<1000:
            return "PILOT"
        case 1000..<2000:
            return "ACE PILOT"
        case 2000..<5000:
            return "COMMANDER"
        default:
            return "LEGENDARY"
        }
    }
    
    private func getRatingColor(_ rating: String) -> UIColor {
        switch rating {
        case "ROOKIE PILOT", "CADET":
            return .gray
        case "PILOT":
            return .green
        case "ACE PILOT":
            return .cyan
        case "COMMANDER":
            return .magenta
        case "LEGENDARY":
            return .yellow
        default:
            return .white
        }
    }
    
    private func animateLabels(_ labels: [SKNode]) {
        for (index, label) in labels.enumerated() {
            label.alpha = 0
            label.setScale(0.5)
            
            let delay = Double(index) * 0.2
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
            let animation = SKAction.group([fadeIn, scaleUp])
            
            label.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                animation
            ]))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            
            if node.name == "playAgain" {
                playAgain()
            } else if node.name == "mainMenu" {
                mainMenu()
            } else {
                // Any tap restarts the game
                playAgain()
            }
        }
    }
    
    private func playAgain() {
        let newGame = GameArena(size: size)
        newGame.scaleMode = scaleMode
        view?.presentScene(newGame, transition: SKTransition.fade(withDuration: 0.5))
    }
    
    private func mainMenu() {
        // For now, restart the game (could implement a proper main menu later)
        playAgain()
    }
}