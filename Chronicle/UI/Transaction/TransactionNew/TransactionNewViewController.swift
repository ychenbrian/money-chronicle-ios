import Foundation
import RxSwift
import SnapKit
import UIKit

protocol TransactionNewViewControllerDelegate: AnyObject {}

class TransactionNewViewController: BaseViewController {
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()

    private let dateRow = TransactionNewDateView()
    private let sourceRow = TransactionNewSourceView()
    private let categoryRow = TransactionNewCategoryView()
    
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
    
    // MARK: - Action
    
    // MARK: - Setup
    
    private func setupView() {
        self.title = String(localized: "transaction.list.title")
        self.view.backgroundColor = .systemBackground
        
        self.view.addSubview(scrollView)
        scrollView.keyboardDismissMode = .interactive

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        scrollView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        mainStackView.addArrangedSubview(dateRow)
        mainStackView.addArrangedSubview(sourceRow)
        mainStackView.addArrangedSubview(categoryRow)
        
        // TODO: handle the selection
    }
    
    private func setupObserve() {}
    
    private func setupBinding() {}
}
