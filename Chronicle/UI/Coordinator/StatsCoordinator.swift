import UIKit

class StatsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = StatsViewModel()
        let viewController = StatsViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: false)
    }
}
