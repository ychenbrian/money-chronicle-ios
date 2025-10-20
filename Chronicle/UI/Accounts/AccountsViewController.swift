import RxCocoa
import RxSwift
import UIKit

class AccountsViewController: BaseViewController {
    private var viewModel: AccountsViewModel!

    convenience init(viewModel: AccountsViewModel) {
        self.init()
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {}
}
