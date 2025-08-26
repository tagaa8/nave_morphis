import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configurar orientación
        setupOrientation()
        
        if let view = self.view as! SKView? {
            // Cargar la escena del menú principal
            let scene = MainMenuScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            // Configuración de debug (solo en desarrollo)
            #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = false
            #endif
        }
        
        setupNotifications()
    }
    
    private func setupOrientation() {
        // Forzar orientación landscape
        if #available(iOS 16.0, *) {
            guard let windowScene = view.window?.windowScene else { return }
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(gameWillResignActive),
            name: NSNotification.Name("GameWillResignActive"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(gameDidEnterBackground),
            name: NSNotification.Name("GameDidEnterBackground"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(gameWillEnterForeground),
            name: NSNotification.Name("GameWillEnterForeground"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(gameDidBecomeActive),
            name: NSNotification.Name("GameDidBecomeActive"),
            object: nil
        )
    }
    
    @objc private func gameWillResignActive() {
        if let skView = view as? SKView,
           let gameScene = skView.scene as? GameScene {
            // Pausar juego si está activo
            gameScene.isPaused = true
        }
    }
    
    @objc private func gameDidEnterBackground() {
        if let skView = view as? SKView {
            skView.isPaused = true
        }
    }
    
    @objc private func gameWillEnterForeground() {
        // Preparar para volver a activar
    }
    
    @objc private func gameDidBecomeActive() {
        if let skView = view as? SKView {
            skView.isPaused = false
        }
        
        if let gameScene = view.subviews.first as? SKView {
            if let scene = gameScene.scene as? GameScene {
                scene.isPaused = false
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .landscape
        }
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
        NotificationCenter.default.removeObserver(self)
    }
}