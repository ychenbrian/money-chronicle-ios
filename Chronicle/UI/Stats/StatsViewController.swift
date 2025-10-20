import RxCocoa
import RxSwift
import UIKit

class StatsViewController: BaseViewController {
    private var viewModel: StatsViewModel!

    convenience init(viewModel: StatsViewModel) {
        self.init()
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {}
}
