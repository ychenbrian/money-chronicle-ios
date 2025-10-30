import UIKit

class TransactionsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private let repository: TransactionRepositoryType

    init(navigationController: UINavigationController, repository: TransactionRepositoryType = TransactionRepository()) {
        self.navigationController = navigationController
        self.repository = repository
    }

    func start() {
        let viewModel = TransactionViewModel(repository: repository)
        let viewController = TransactionsListViewController(viewModel: viewModel, delegate: self)
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func startTransactionNew() {
        let viewModel = TransactionNewViewModel(repository: repository)
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
