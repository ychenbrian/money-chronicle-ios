import RxCocoa
import RxSwift
import SnapKit
import UIKit

class TransactionsViewController: BaseViewController {
    // MARK: - UI Components

    private let tableView = UITableView(frame: .zero, style: .grouped)

    // MARK: - Properties

    private var viewModel: TransactionViewModel!
    private let disposeBag = DisposeBag()

    private let titleCellID = "TransactionTitleCell"
    private let transCellID = "TransactionCell"

    // MARK: - Lifecycle

    convenience init(viewModel: TransactionViewModel) {
        self.init()
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupObserve()
        setupBinding()
        viewModel.loadMockTransactions()
    }

    // MARK: - Setup

    private func setupView() {
        title = String(localized: "transaction.vc.title")
        view.addSubview(tableView)
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

extension TransactionsViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat { .leastNormalMagnitude }
    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat { .leastNormalMagnitude }
    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? { nil }
    func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? { nil }
}
