import RxCocoa
import RxSwift
import SnapKit
import UIKit

class TransactionsViewController: BaseViewController {
    // MARK: - UI Components

    private let tableView = UITableView(frame: .zero, style: .grouped)

    // MARK: - Properties

    private var viewModel: TransactionsViewModel!
    private let disposeBag = DisposeBag()

    private let titleCellID = "TransactionTitleCell"
    private let transCellID = "TransactionCell"

    private var transactionGroups: [UIModel.TransactionGroup] = []

    // MARK: - Lifecycle

    convenience init(viewModel: TransactionsViewModel) {
        self.init()
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupObserve()
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

        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupObserve() {
        viewModel.transGroups
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDataSource

extension TransactionsViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return transactionGroups.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionGroups[section].transactions.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let group = transactionGroups[indexPath.section]

        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: titleCellID, for: indexPath) as? TransactionTitleCell else {
                return UITableViewCell()
            }
            cell.transactionGroup = group
            cell.selectionStyle = .none
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: transCellID, for: indexPath) as? TransactionCell else {
            return UITableViewCell()
        }

        let transactionIndex = indexPath.row - 1
        cell.transaction = group.transactions[transactionIndex]
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TransactionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard indexPath.row > 0 else { return }

        let group = transactionGroups[indexPath.section]
        let transactionIndex = indexPath.row - 1
        let selectedTransaction = group.transactions[transactionIndex]
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        return nil
    }

    func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return nil
    }
}
