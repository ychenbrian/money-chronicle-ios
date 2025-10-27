import Foundation
import RxSwift
import SnapKit
import UIKit

protocol TransactionNewViewControllerDelegate: AnyObject {}

class TransactionNewViewController: BaseViewController {
    // MARK: - UI Components
    
    // MARK: - Properties

    private(set) weak var delegate: TransactionNewViewControllerDelegate?
    private var viewModel: TransactionNewViewModel!
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    convenience init(viewModel: TransactionNewViewModel, delegate: TransactionNewViewControllerDelegate) {
        self.init()
        self.viewModel = viewModel
        self.delegate = delegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupObserve()
        setupBinding()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        self.title = "New Transaction"
        self.view.backgroundColor = .systemBackground
    }
    
    private func setupObserve() {}
    
    private func setupBinding() {}
}
