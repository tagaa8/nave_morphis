import SpriteKit
import SwiftUI

class MainMenuScene: SKScene {
    
    private var playButton: SKLabelNode?
    private var optionsButton: SKLabelNode?
    private var quitButton: SKLabelNode?
    private var titleLabel: SKLabelNode?
    private var backgroundNode: SKSpriteNode?
    private var starField: SKEmitterNode?
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupStarField()
        setupUI()
        setupAnimations()
    }
    
    private func setupBackground() {
        backgroundColor = SKColor.black
        
        backgroundNode = SKSpriteNode(color: .black, size: size)
        backgroundNode?.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundNode?.zPosition = -10
        addChild(backgroundNode!)
        
        for i in 0..<5 {
            let nebula = createNebula(layer: i)
            addChild(nebula)
        }
    }
    
    private func createNebula(layer: Int) -> SKSpriteNode {
        let nebulaSize = CGSize(width: size.width * 1.2, height: size.height * 1.2)
        let nebula = SKSpriteNode(color: .purple.withAlphaComponent(0.1 + Float(layer) * 0.05), size: nebulaSize)
        nebula.position = CGPoint(x: frame.midX, y: frame.midY)
        nebula.zPosition = CGFloat(-9 + layer)
        nebula.blendMode = .add
        
        let moveAction = SKAction.moveBy(x: -size.width, y: 0, duration: TimeInterval(20 + layer * 5))
        let resetAction = SKAction.moveBy(x: size.width * 2, y: 0, duration: 0)
        let sequenceAction = SKAction.sequence([moveAction, resetAction])
        nebula.run(SKAction.repeatForever(sequenceAction))
        
        return nebula
    }
    
    private func setupStarField() {
        starField = SKEmitterNode()
        starField?.particleTexture = SKTexture(imageNamed: "spark")
        starField?.particleBirthRate = 50
        starField?.particleLifetime = 10
        starField?.particlePositionRange = CGVector(dx: size.width, dy: size.height)
        starField?.particleSpeed = -50
        starField?.particleSpeedRange = 30
        starField?.particleScale = 0.1
        starField?.particleScaleRange = 0.05
        starField?.particleColor = .white
        starField?.particleAlpha = 0.8
        starField?.particleAlphaRange = 0.4
        starField?.emissionAngle = 0
        starField?.position = CGPoint(x: size.width, y: frame.midY)
        starField?.zPosition = -5
        
        if let starField = starField {
            addChild(starField)
        }
    }
    
    private func setupUI() {
        titleLabel = SKLabelNode(text: "NAVE MORPHIS")
        titleLabel?.fontName = "Helvetica-Bold"
        titleLabel?.fontSize = 48
        titleLabel?.fontColor = .cyan
        titleLabel?.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        titleLabel?.zPosition = 10
        
        if let titleLabel = titleLabel {
            addChild(titleLabel)
        }
        
        playButton = createButton(text: "PLAY", position: CGPoint(x: frame.midX, y: frame.midY + 50))
        optionsButton = createButton(text: "OPTIONS", position: CGPoint(x: frame.midX, y: frame.midY))
        quitButton = createButton(text: "QUIT", position: CGPoint(x: frame.midX, y: frame.midY - 50))
        
        if let playButton = playButton,
           let optionsButton = optionsButton,
           let quitButton = quitButton {
            addChild(playButton)
            addChild(optionsButton)
            addChild(quitButton)
        }
        
        let versionLabel = SKLabelNode(text: "v1.0.0")
        versionLabel.fontName = "Helvetica"
        versionLabel.fontSize = 16
        versionLabel.fontColor = .gray
        versionLabel.position = CGPoint(x: frame.maxX - 50, y: frame.minY + 30)
        versionLabel.zPosition = 10
        addChild(versionLabel)
    }
    
    private func createButton(text: String, position: CGPoint) -> SKLabelNode {
        let button = SKLabelNode(text: text)
        button.fontName = "Helvetica-Bold"
        button.fontSize = 32
        button.fontColor = .white
        button.position = position
        button.zPosition = 10
        button.name = text.lowercased()
        
        let background = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 10)
        background.fillColor = .darkGray.withAlphaComponent(0.3)
        background.strokeColor = .cyan
        background.lineWidth = 2
        background.zPosition = -1
        background.alpha = 0.8
        button.addChild(background)
        
        return button
    }
    
    private func setupAnimations() {
        let titleGlow = SKAction.sequence([
            SKAction.colorize(with: .cyan, colorBlendFactor: 1.0, duration: 1.0),
            SKAction.colorize(with: .magenta, colorBlendFactor: 1.0, duration: 1.0)
        ])
        titleLabel?.run(SKAction.repeatForever(titleGlow))
        
        let titlePulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1.5),
            SKAction.scale(to: 1.0, duration: 1.5)
        ])
        titleLabel?.run(SKAction.repeatForever(titlePulse))
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
        case "play":
            startGame()
        case "options":
            showOptions()
        case "quit":
            quitGame()
        default:
            break
        }
    }
    
    private func startGame() {
        SoundManager.shared.playSound(.menuConfirm)
        
        let transition = SKTransition.fade(withDuration: 1.0)
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        
        view?.presentScene(gameScene, transition: transition)
    }
    
    private func showOptions() {
        
        let alert = UIAlertController(title: "Options", message: "Game options would go here", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let viewController = view?.window?.rootViewController {
            viewController.present(alert, animated: true)
        }
    }
    
    private func quitGame() {
        exit(0)
    }
}