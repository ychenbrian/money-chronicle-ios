import UIKit

class StatsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = StatsMainViewModel()
        let viewController = StatsMainViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: false)
    }
}
