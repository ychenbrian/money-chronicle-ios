import UIKit

class TransactionsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = TransactionViewModel()
        let viewController = TransactionsViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: false)
    }
}
