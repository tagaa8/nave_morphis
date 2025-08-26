import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let gameViewController = GameViewController()
        window?.rootViewController = gameViewController
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name("GameWillResignActive"), object: nil)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name("GameDidEnterBackground"), object: nil)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name("GameWillEnterForeground"), object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name("GameDidBecomeActive"), object: nil)
    }
}