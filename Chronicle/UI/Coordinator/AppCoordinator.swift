import UIKit

class AppCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var tabBarController: UITabBarController

    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }

    func start() {
        let tabs = setupTabs()
        tabBarController.viewControllers = tabs
        tabBarController.tabBar.tintColor = .systemBlue
    }

    private func setupTabs() -> [UIViewController] {
        // Transactions Tab
        let transactionsNav = UINavigationController()
        transactionsNav.tabBarItem = UITabBarItem(
            title: String(localized: "tab.transaction.title"),
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )
        let transactionsCoordinator = TransactionsCoordinator(navigationController: transactionsNav)
        childCoordinators.append(transactionsCoordinator)
        transactionsCoordinator.start()

        // Stats Tab
        let statsNav = UINavigationController()
        statsNav.tabBarItem = UITabBarItem(
            title: String(localized: "tab.stats.title"),
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )
        let statsCoordinator = StatsCoordinator(navigationController: statsNav)
        childCoordinators.append(statsCoordinator)
        statsCoordinator.start()

        // Accounts Tab
        let accountsNav = UINavigationController()
        accountsNav.tabBarItem = UITabBarItem(
            title: String(localized: "tab.accounts.title"),
            image: UIImage(systemName: "creditcard"),
            selectedImage: UIImage(systemName: "creditcard.fill")
        )
        let accountsCoordinator = AccountsCoordinator(navigationController: accountsNav)
        childCoordinators.append(accountsCoordinator)
        accountsCoordinator.start()

        // Settings Tab
        let settingsNav = UINavigationController()
        settingsNav.tabBarItem = UITabBarItem(
            title: String(localized: "tab.settings.title"),
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )
        let settingsCoordinator = SettingsCoordinator(navigationController: settingsNav)
        childCoordinators.append(settingsCoordinator)
        settingsCoordinator.start()

        return [transactionsNav, statsNav, accountsNav, settingsNav]
    }
}
