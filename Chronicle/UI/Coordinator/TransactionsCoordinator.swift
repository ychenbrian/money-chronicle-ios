import UIKit

class TransactionsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = TransactionViewModel()
        let viewController = TransactionsListViewController(viewModel: viewModel, delegate: self)
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func startTransactionNew() {
        let viewModel = TransactionNewViewModel()
        let viewController = TransactionNewViewController(viewModel: viewModel, delegate: self)
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - TransactionViewControllerDelegate

extension TransactionsCoordinator: TransactionListViewControllerDelegate {
    func transactionListViewControllerAddNewTransaction() {
        startTransactionNew()
    }
}

// MARK: - TransactionNewViewControllerDelegate

extension TransactionsCoordinator: TransactionNewViewControllerDelegate {}
