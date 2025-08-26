import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            let scene = MainMenuScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = false
        }
        
        setupNotifications()
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
            gameScene.pauseGame()
        }
    }
    
    @objc private func gameDidEnterBackground() {
        if let skView = view as? SKView {
            skView.isPaused = true
        }
    }
    
    @objc private func gameWillEnterForeground() {
        
    }
    
    @objc private func gameDidBecomeActive() {
        if let skView = view as? SKView {
            skView.isPaused = false
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}