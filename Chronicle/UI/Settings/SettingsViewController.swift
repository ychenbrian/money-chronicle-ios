import RxCocoa
import RxSwift
import UIKit

class SettingsViewController: BaseViewController {
    private var viewModel: SettingsViewModel!

    convenience init(viewModel: SettingsViewModel) {
        self.init()
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {}
}
