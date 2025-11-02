import SnapKit
import UIKit

class TransactionTitleCell: UITableViewCell {
    // MARK: - UI Components

    private let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.textColor = .appColor(.secondaryTextColor)
        return label
    }()

    private let totalAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 1
        label.textColor = .appColor(.secondaryTextColor)
        label.textAlignment = .right
        return label
    }()

    // MARK: - Properties

    var transactionGroup: UIModel.TransactionGroup? {
        didSet {
            setupData(transactionGroup)
        }
    }

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = .clear

        contentView.addSubview(titleStackView)

        titleStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-32)
        }

        titleStackView.addArrangedSubview(dateLabel)
        titleStackView.addArrangedSubview(totalAmountLabel)
    }

    private func setupData(_ transactionGroup: UIModel.TransactionGroup?) {
        guard let transactionGroup else { return }

        dateLabel.text = (transactionGroup.date ?? Date()).asDayMonthString
        totalAmountLabel.text = String(format: "£%.2f", transactionGroup.totalAmount)
    }
}
