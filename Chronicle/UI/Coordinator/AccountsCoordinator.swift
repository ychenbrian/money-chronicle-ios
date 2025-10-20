import UIKit

class AccountsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = AccountsViewModel()
        let viewController = AccountsViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: false)
    }
}
