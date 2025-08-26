import SpriteKit

class PauseScene: SKScene {
    
    private var resumeButton: SKLabelNode?
    private var restartButton: SKLabelNode?
    private var mainMenuButton: SKLabelNode?
    private var pauseLabel: SKLabelNode?
    
    private weak var gameScene: GameScene?
    
    init(size: CGSize, gameScene: GameScene) {
        self.gameScene = gameScene
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupUI()
    }
    
    private func setupBackground() {
        backgroundColor = .clear
        
        let overlay = SKSpriteNode(color: .black.withAlphaComponent(0.7), size: size)
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        overlay.zPosition = 0
        addChild(overlay)
        
        let pauseBackground = SKShapeNode(rectOf: CGSize(width: 300, height: 400), cornerRadius: 20)
        pauseBackground.fillColor = .darkGray.withAlphaComponent(0.9)
        pauseBackground.strokeColor = .cyan
        pauseBackground.lineWidth = 3
        pauseBackground.position = CGPoint(x: frame.midX, y: frame.midY)
        pauseBackground.zPosition = 1
        addChild(pauseBackground)
    }
    
    private func setupUI() {
        pauseLabel = SKLabelNode(text: "PAUSED")
        pauseLabel?.fontName = "Helvetica-Bold"
        pauseLabel?.fontSize = 36
        pauseLabel?.fontColor = .cyan
        pauseLabel?.position = CGPoint(x: frame.midX, y: frame.midY + 120)
        pauseLabel?.zPosition = 10
        
        if let pauseLabel = pauseLabel {
            addChild(pauseLabel)
        }
        
        resumeButton = createButton(text: "RESUME", position: CGPoint(x: frame.midX, y: frame.midY + 50))
        restartButton = createButton(text: "RESTART", position: CGPoint(x: frame.midX, y: frame.midY))
        mainMenuButton = createButton(text: "MAIN MENU", position: CGPoint(x: frame.midX, y: frame.midY - 50))
        
        if let resumeButton = resumeButton,
           let restartButton = restartButton,
           let mainMenuButton = mainMenuButton {
            addChild(resumeButton)
            addChild(restartButton)
            addChild(mainMenuButton)
        }
        
        let instructionLabel = SKLabelNode(text: "Tap anywhere to resume")
        instructionLabel.fontName = "Helvetica"
        instructionLabel.fontSize = 16
        instructionLabel.fontColor = .lightGray
        instructionLabel.position = CGPoint(x: frame.midX, y: frame.midY - 120)
        instructionLabel.zPosition = 10
        addChild(instructionLabel)
        
        setupAnimations()
    }
    
    private func createButton(text: String, position: CGPoint) -> SKLabelNode {
        let button = SKLabelNode(text: text)
        button.fontName = "Helvetica-Bold"
        button.fontSize = 24
        button.fontColor = .white
        button.position = position
        button.zPosition = 10
        button.name = text.lowercased().replacingOccurrences(of: " ", with: "_")
        
        let background = SKShapeNode(rectOf: CGSize(width: 200, height: 40), cornerRadius: 8)
        background.fillColor = .gray.withAlphaComponent(0.3)
        background.strokeColor = .white
        background.lineWidth = 1
        background.zPosition = -1
        background.alpha = 0.8
        button.addChild(background)
        
        return button
    }
    
    private func setupAnimations() {
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        pauseLabel?.run(SKAction.repeatForever(pulse))
        
        let glow = SKAction.sequence([
            SKAction.colorize(with: .cyan, colorBlendFactor: 1.0, duration: 1.0),
            SKAction.colorize(with: .magenta, colorBlendFactor: 1.0, duration: 1.0)
        ])
        pauseLabel?.run(SKAction.repeatForever(glow))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if let buttonName = touchedNode.name ?? touchedNode.parent?.name {
            handleButtonTap(buttonName)
        } else {
            resumeGame()
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
        case "resume":
            resumeGame()
        case "restart":
            restartGame()
        case "main_menu":
            goToMainMenu()
        default:
            break
        }
    }
    
    private func resumeGame() {
        SoundManager.shared.playSound(.menuConfirm)
        gameScene?.resumeGame()
        removeFromParent()
    }
    
    private func restartGame() {
        SoundManager.shared.playSound(.menuConfirm)
        
        let transition = SKTransition.fade(withDuration: 0.5)
        let newGameScene = GameScene(size: size)
        newGameScene.scaleMode = scaleMode
        
        view?.presentScene(newGameScene, transition: transition)
    }
    
    private func goToMainMenu() {
        SoundManager.shared.playSound(.menuConfirm)
        
        let transition = SKTransition.fade(withDuration: 0.5)
        let mainMenuScene = MainMenuScene(size: size)
        mainMenuScene.scaleMode = scaleMode
        
        view?.presentScene(mainMenuScene, transition: transition)
    }
}