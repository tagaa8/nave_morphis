import SpriteKit

class MainMenuScene: SKScene {
    
    private var playButton: SKLabelNode?
    private var titleLabel: SKLabelNode?
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupBackground()
        setupUI()
    }
    
    private func setupBackground() {
        // Crear campo de estrellas simple
        for _ in 0..<100 {
            let star = SKSpriteNode(color: .white, size: CGSize(width: 2, height: 2))
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.alpha = CGFloat.random(in: 0.3...1.0)
            addChild(star)
            
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 1...3)),
                SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 1...3))
            ])
            star.run(SKAction.repeatForever(twinkle))
        }
    }
    
    private func setupUI() {
        titleLabel = SKLabelNode(text: "NAVE MORPHIS")
        titleLabel?.fontName = "Helvetica-Bold"
        titleLabel?.fontSize = 48
        titleLabel?.fontColor = .cyan
        titleLabel?.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        
        playButton = SKLabelNode(text: "TAP TO PLAY")
        playButton?.fontName = "Helvetica-Bold"
        playButton?.fontSize = 32
        playButton?.fontColor = .white
        playButton?.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        playButton?.name = "play"
        
        if let titleLabel = titleLabel, let playButton = playButton {
            addChild(titleLabel)
            addChild(playButton)
        }
        
        // Efectos de animación
        let titleGlow = SKAction.sequence([
            SKAction.colorize(with: .cyan, colorBlendFactor: 1.0, duration: 1.0),
            SKAction.colorize(with: .magenta, colorBlendFactor: 1.0, duration: 1.0)
        ])
        titleLabel?.run(SKAction.repeatForever(titleGlow))
        
        let buttonPulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 1.0),
            SKAction.fadeAlpha(to: 1.0, duration: 1.0)
        ])
        playButton?.run(SKAction.repeatForever(buttonPulse))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startGame()
    }
    
    private func startGame() {
        let transition = SKTransition.fade(withDuration: 0.5)
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        
        view?.presentScene(gameScene, transition: transition)
    }
}