import UIKit
import SceneKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the new 3D game instead of the 2D arena
        let game3DViewController = Game3DViewController()
        
        addChild(game3DViewController)
        view.addSubview(game3DViewController.view)
        game3DViewController.view.frame = view.bounds
        game3DViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        game3DViewController.didMove(toParent: self)
    }
    

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
}