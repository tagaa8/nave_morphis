import UIKit
import SceneKit

class Game3DViewController: UIViewController {
    
    // MARK: - Properties
    private var sceneView: SCNView!
    private var gameScene: Game3DScene!
    private var displayLink: CADisplayLink?
    
    // MARK: - UI Elements
    private var scoreLabel: UILabel!
    private var livesLabel: UILabel!
    private var waveLabel: UILabel!
    private var controlsOverlay: UIView!
    private var virtualJoystick: VirtualJoystick3D!
    private var fireButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSceneView()
        setupGameScene()
        setupUI()
        setupControls()
        startGameLoop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Force landscape orientation
        if #available(iOS 16.0, *) {
            setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
    
    private func setupSceneView() {
        sceneView = SCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.backgroundColor = UIColor.black
        
        // SceneKit settings for better performance and quality
        sceneView.antialiasingMode = .multisampling2X // Balanced quality
        sceneView.preferredFramesPerSecond = 60
        sceneView.allowsCameraControl = true // Allow camera rotation
        sceneView.showsStatistics = false
        
        // Performance optimizations
        sceneView.rendersContinuously = true
        
        // Debug options (disable in production)
        #if DEBUG
        sceneView.debugOptions = []
        #endif
        
        view.addSubview(sceneView)
    }
    
    private func setupGameScene() {
        gameScene = Game3DScene()
        sceneView.scene = gameScene
        sceneView.delegate = self
    }
    
    private func setupUI() {
        // Score label
        scoreLabel = UILabel()
        scoreLabel.text = "SCORE: 0"
        scoreLabel.textColor = .cyan
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 20)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)
        
        // Lives label
        livesLabel = UILabel()
        livesLabel.text = "LIVES: ♦♦♦"
        livesLabel.textColor = .green
        livesLabel.font = UIFont.boldSystemFont(ofSize: 20)
        livesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(livesLabel)
        
        // Wave label
        waveLabel = UILabel()
        waveLabel.text = "WAVE 1"
        waveLabel.textColor = .yellow
        waveLabel.font = UIFont.boldSystemFont(ofSize: 20)
        waveLabel.textAlignment = .center
        waveLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(waveLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            livesLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            livesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            waveLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            waveLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupControls() {
        controlsOverlay = UIView()
        controlsOverlay.backgroundColor = UIColor.clear
        controlsOverlay.isUserInteractionEnabled = true
        controlsOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlsOverlay)
        
        NSLayoutConstraint.activate([
            controlsOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            controlsOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Virtual joystick
        virtualJoystick = VirtualJoystick3D(frame: CGRect(x: 50, y: view.bounds.height - 200, width: 150, height: 150))
        virtualJoystick.delegate = self
        controlsOverlay.addSubview(virtualJoystick)
        
        // Fire button
        fireButton = UIButton()
        fireButton.setTitle("🔥", for: .normal)
        fireButton.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        fireButton.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        fireButton.layer.cornerRadius = 40
        fireButton.frame = CGRect(x: view.bounds.width - 130, y: view.bounds.height - 200, width: 80, height: 80)
        fireButton.addTarget(self, action: #selector(fireButtonPressed), for: .touchDown)
        fireButton.addTarget(self, action: #selector(fireButtonReleased), for: [.touchUpInside, .touchUpOutside])
        controlsOverlay.addSubview(fireButton)
        
        // Additional control buttons for 3D movement
        let upButton = createControlButton(title: "⬆️", action: #selector(upButtonPressed))
        upButton.frame = CGRect(x: view.bounds.width - 130, y: view.bounds.height - 350, width: 50, height: 50)
        controlsOverlay.addSubview(upButton)
        
        let downButton = createControlButton(title: "⬇️", action: #selector(downButtonPressed))
        downButton.frame = CGRect(x: view.bounds.width - 130, y: view.bounds.height - 290, width: 50, height: 50)
        controlsOverlay.addSubview(downButton)
    }
    
    private func createControlButton(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.backgroundColor = UIColor.blue.withAlphaComponent(0.3)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: action, for: .touchDown)
        return button
    }
    
    private func startGameLoop() {
        displayLink = CADisplayLink(target: self, selector: #selector(gameLoop))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    @objc private func gameLoop() {
        // Update game scene
        let currentTime = CACurrentMediaTime()
        gameScene.update(atTime: currentTime, in: sceneView)
        
        // Update UI
        updateUI()
    }
    
    private func updateUI() {
        // This would be connected to the game scene's state
        // For now, placeholder updates
        scoreLabel.text = "SCORE: 0" // gameScene.score
        livesLabel.text = "LIVES: ♦♦♦" // gameScene.lives
        waveLabel.text = "WAVE 1" // gameScene.wave
    }
    
    // MARK: - Control Actions
    @objc private func fireButtonPressed() {
        gameScene.handleInput(keyCode: 49, isPressed: true) // Space key
    }
    
    @objc private func fireButtonReleased() {
        gameScene.handleInput(keyCode: 49, isPressed: false)
    }
    
    @objc private func upButtonPressed() {
        gameScene.handleInput(keyCode: 12, isPressed: true) // Q key
    }
    
    @objc private func downButtonPressed() {
        gameScene.handleInput(keyCode: 14, isPressed: true) // E key
    }
    
    // MARK: - Orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    deinit {
        displayLink?.invalidate()
    }
}

// MARK: - SCNSceneRendererDelegate
extension Game3DViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Additional rendering updates if needed
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        // Post-render updates if needed
    }
}

// MARK: - VirtualJoystick3D Delegate
protocol VirtualJoystick3DDelegate: AnyObject {
    func joystickMoved(x: Float, z: Float)
}

extension Game3DViewController: VirtualJoystick3DDelegate {
    func joystickMoved(x: Float, z: Float) {
        // Convert joystick input to game movement (fixed directions)
        gameScene.handleInput(keyCode: 0, isPressed: x < -0.3) // A key (left)
        gameScene.handleInput(keyCode: 2, isPressed: x > 0.3)  // D key (right)
        gameScene.handleInput(keyCode: 13, isPressed: z > 0.3) // W key (forward) - FIXED
        gameScene.handleInput(keyCode: 1, isPressed: z < -0.3)  // S key (backward) - FIXED
    }
}