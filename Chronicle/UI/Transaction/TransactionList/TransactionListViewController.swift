import RxCocoa
import RxSwift
import SnapKit
import UIKit

protocol TransactionListViewControllerDelegate: AnyObject {
    func transactionListViewControllerAddNewTransaction()
}

class TransactionsListViewController: BaseViewController {
    // MARK: - UI Components

    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    private let newTransactionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 32, weight: .bold)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 4
        return button
    }()
    
    // MARK: - Properties

    private(set) weak var delegate: TransactionListViewControllerDelegate?
    private var viewModel: TransactionViewModel!
    private let disposeBag = DisposeBag()

    private let titleCellID = "TransactionTitleCell"
    private let transCellID = "TransactionCell"

    // MARK: - Lifecycle

    convenience init(viewModel: TransactionViewModel, delegate: TransactionListViewControllerDelegate) {
        self.init()
        self.viewModel = viewModel
        self.delegate = delegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupObserve()
        setupBinding()
        viewModel.loadTransactions()
    }
    
    // MARK: - Actions
    
    @objc private func startTransactionNew() {
        self.delegate?.transactionListViewControllerAddNewTransaction()
    }

    // MARK: - Setup

    private func setupView() {
        self.title = String(localized: "transaction.list.title")
        self.view.backgroundColor = .systemBackground
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        tableView.register(TransactionTitleCell.self, forCellReuseIdentifier: titleCellID)
        tableView.register(TransactionCell.self, forCellReuseIdentifier: transCellID)

        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear

        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        newTransactionButton.addTarget(self, action: #selector(startTransactionNew), for: .touchUpInside)
        self.view.addSubview(newTransactionButton)
        newTransactionButton.snp.makeConstraints { make in
            make.width.height.equalTo(56)
            make.trailing.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
    }

    private func setupObserve() {}
    
    private func setupBinding() {
        viewModel.rows
            .drive(tableView.rx.items) { [weak self] tableView, _, item in
                guard let self = self else { return UITableViewCell() }
                switch item {
                case .title(let group):
                    let cell = tableView.dequeueReusableCell(withIdentifier: self.titleCellID) as! TransactionTitleCell
                    cell.transactionGroup = group
                    cell.selectionStyle = .none
                    return cell
                case .transaction(let tx):
                    let cell = tableView.dequeueReusableCell(withIdentifier: self.transCellID) as! TransactionCell
                    cell.transaction = tx
                    cell.selectionStyle = .none
                    return cell
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate

extension TransactionsListViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat { .leastNormalMagnitude }
    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat { .leastNormalMagnitude }
    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? { nil }
    func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? { nil }
}
