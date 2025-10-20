import RxCocoa
import RxSwift
import UIKit

class TransactionsViewController: BaseViewController {
    private var viewModel: TransactionsViewModel!

    convenience init(viewModel: TransactionsViewModel) {
        self.init()
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {}
}
