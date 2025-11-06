import Foundation
import RxCocoa
import RxSwift
import SnapKit
import UIKit

protocol TransactionEditViewControllerDelegate: AnyObject {}

final class TransactionEditViewController: BaseViewController {
    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private var deleteButton: UIBarButtonItem?

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()

    private let dateRow = TransactionEditDateView()
    private let sourceRow = TransactionEditSourceView()
    private let categoryRow = TransactionEditCategoryView()
    private let amountRow = TransactionEditAmountView()
    private let noteRow = TransactionEditNoteView()
    private let digitPadRow = TransactionEditDigitPadView()
    private let buttonRow = TransactionEditButtonView()

    // MARK: - Properties

    private(set) weak var delegate: TransactionEditViewControllerDelegate?
    private var viewModel: TransactionEditViewModel!
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    convenience init(viewModel: TransactionEditViewModel, delegate: TransactionEditViewControllerDelegate) {
        self.init()
        self.viewModel = viewModel
        self.delegate = delegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBinding()
    }
    
    // MARK: - Setup

    private func setupView() {
        self.title = viewModel.isEditing ? String(localized: "transaction.edit.title") : String(localized: "transaction.new.title")
        self.view.backgroundColor = .systemBackground

        self.view.addSubview(scrollView)
        scrollView.keyboardDismissMode = .interactive
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }

        scrollView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        [dateRow, sourceRow, categoryRow, amountRow, digitPadRow, noteRow, buttonRow].forEach {
            mainStackView.addArrangedSubview($0)
        }

        digitPadRow.isHidden = true
        digitPadRow.snp.makeConstraints { make in
            digitPadHeight = make.height.equalTo(0).constraint
        }
        
        setupNavBar()
        setupCallbacks()
    }
    
    private func setupNavBar() {
        guard viewModel.isEditing else { return }

        deleteButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(didTapDelete)
        )
        deleteButton?.accessibilityLabel = String(localized: "transaction.delete.accessibility")
        deleteButton?.tintColor = .systemRed
        navigationItem.rightBarButtonItems = [deleteButton!]
    }
    
    private func setupBinding() {
        if viewModel.isEditing {
            viewModel.transaction
                .asObservable()
                .take(1)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] in
                    self?.applyToSubviews($0)
                })
                .disposed(by: disposeBag)
        }

        viewModel.isSaveEnabled
            .drive(onNext: { [weak self] enabled in
                self?.buttonRow.setEnabled(enabled)
            })
            .disposed(by: disposeBag)

        viewModel.event
            .emit(onNext: { [weak self] event in
                switch event {
                case .transactionSaved, .transactionDeleted:
                    self?.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)

        viewModel.error
            .emit(onNext: { [weak self] err in self?.presentError(err) })
            .disposed(by: disposeBag)
    }

    private func setupCallbacks() {
        digitPadRow.onDigit = { [weak self] digit in self?.amountRow.apply(.digit(digit)) }
        digitPadRow.onDecimal = { [weak self] in self?.amountRow.apply(.decimal) }
        digitPadRow.onBackspace = { [weak self] in self?.amountRow.apply(.backspace) }
        digitPadRow.onClearAll = { [weak self] in self?.amountRow.apply(.clearAll) }

        amountRow.onRequestInput = { [weak self] in self?.toggleDigitPad() }

        buttonRow.onSave = { [weak self] in
            guard let self else { return }
            view.endEditing(true)
            updateTransaction()
            _ = viewModel.save()
        }
    }
    
    // MARK: - Action
    
    @objc private func didTapDelete() {
        let alert = UIAlertController(
            title: String(localized: "transaction.delete.title"),
            message: String(localized: "transaction.delete.confirm"),
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: String(localized: "common.cancel"), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: String(localized: "common.delete"), style: .destructive, handler: { [weak self] _ in
            self?.viewModel.deleteTransaction()
        }))

        if let pop = alert.popoverPresentationController, let button = deleteButton {
            pop.barButtonItem = button
        }
        present(alert, animated: true)
    }

    // MARK: - Helper

    private func applyToSubviews(_ uiModel: UIModel.Transaction) {
        dateRow.setDate(uiModel.date ?? .init())
        sourceRow.setSource(uiModel.source ?? .debitCard)
        categoryRow.setCategory(uiModel.category ?? .foodAndDrink)

        if let amount = uiModel.amount {
            amountRow.setAmount(Decimal(amount))
        } else {
            amountRow.setAmount(Decimal(0))
        }

        noteRow.setNote(uiModel.note ?? "")
    }

    private func updateTransaction() {
        viewModel.setDate(dateRow.getDate())
        viewModel.setSource(sourceRow.getSource())
        viewModel.setCategory(categoryRow.getCategory())

        let decAmount: Decimal = Decimal(amountRow.getAmount())
        let amountDouble = NSDecimalNumber(decimal: decAmount).doubleValue
        viewModel.setAmount(amountDouble)

        viewModel.setNote(noteRow.getNote())
    }

    private func presentError(_ error: Error) {
        let alert = UIAlertController(
            title: String(localized: "common.error"),
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: String(localized: "common.ok"), style: .default))
        present(alert, animated: true)
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
