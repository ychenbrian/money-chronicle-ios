import Foundation
import RxCocoa
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
    private let amountRow = TransactionNewAmountView()
    private let noteRow = TransactionNewNoteView()
    private let digitPadRow = TransactionNewDigitPadView()
    private let buttonRow = TransactionNewButtonView()
    
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
        self.title = String(localized: "transaction.new.title")
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
        mainStackView.addArrangedSubview(amountRow)
        mainStackView.addArrangedSubview(digitPadRow)
        mainStackView.addArrangedSubview(noteRow)
        mainStackView.addArrangedSubview(buttonRow)
        
        digitPadRow.isHidden = true
        digitPadRow.snp.makeConstraints { make in
            digitPadHeight = make.height.equalTo(0).constraint
        }
        
        digitPadRow.onDigit = { [weak self] digit in
            self?.amountRow.apply(.digit(digit))
        }
        
        digitPadRow.onDecimal = { [weak self] in
            self?.amountRow.apply(.decimal)
        }
        
        digitPadRow.onBackspace = { [weak self] in
            self?.amountRow.apply(.backspace)
        }
        
        digitPadRow.onClearAll = { [weak self] in
            self?.amountRow.apply(.clearAll)
        }
        
        amountRow.onRequestInput = { [weak self] in
            self?.toggleDigitPad()
        }
        
        buttonRow.onSave = { [weak self] in
            self?.view.endEditing(true)
            self?.updateTransaction()
            self?.viewModel.saveTransaction()
        }
    }
    
    private func setupObserve() {}
    
    private func setupBinding() {
        viewModel.event
            .bind(onNext: { [weak self] evt in
                switch evt {
                case .transactionSaved:
                    self?.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func updateTransaction() {
        viewModel.setDate(dateRow.getDate())
        viewModel.setSource(sourceRow.getSource())
        viewModel.setCategory(categoryRow.getCategory())
        viewModel.setAmount(amountRow.getAmount())
        viewModel.setNote(noteRow.getNote())
    }
    
    // MARK: - Digit Pad

    private var isPadVisible = false
    private var digitPadHeight: Constraint?
    
    private func toggleDigitPad() {
        setDigitPad(visible: !isPadVisible, animated: true)
    }

    private func setDigitPad(visible: Bool, animated: Bool) {
        guard visible != isPadVisible else { return }
        isPadVisible = visible

        let targetHeight: CGFloat = visible ? 240 : 0
        digitPadHeight?.update(offset: targetHeight)
        digitPadRow.isHidden = !visible

        let animations = {
            self.view.layoutIfNeeded()
            if visible {
                let rect = self.mainStackView.convert(self.amountRow.bounds, from: self.amountRow)
                self.scrollView.scrollRectToVisible(rect.insetBy(dx: 0, dy: -16), animated: false)
            }
        }

        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: animations)
        } else {
            animations()
        }
    }
}
