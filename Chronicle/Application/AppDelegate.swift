import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        let tabBarController = UITabBarController()
        appCoordinator = AppCoordinator(tabBarController: tabBarController)
        appCoordinator?.start()

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        return true
    }
}
