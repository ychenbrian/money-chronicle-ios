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
        let viewModel = TransactionEditViewModel(repository: repository)
        let viewController = TransactionEditViewController(viewModel: viewModel, delegate: self)
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func startTransactionEdit(_ transaction: UIModel.Transaction, _ id: String) {
        let viewModel = TransactionEditViewModel(repository: repository, existing: transaction, id: id)
        let viewController = TransactionEditViewController(viewModel: viewModel, delegate: self)
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - TransactionViewControllerDelegate

extension TransactionsCoordinator: TransactionListViewControllerDelegate {
    func transactionListViewControllerAddNewTransaction() {
        startTransactionNew()
    }
    
    func transactionListViewControllerEditTransaction(_ transaction: UIModel.Transaction) {
        if let id = transaction.id {
            startTransactionEdit(transaction, id)
        } else {
            startTransactionNew()
        }
    }
}

// MARK: - TransactionNewViewControllerDelegate

extension TransactionsCoordinator: TransactionEditViewControllerDelegate {}
