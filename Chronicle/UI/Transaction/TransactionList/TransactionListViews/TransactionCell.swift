import SnapKit
import UIKit

class TransactionCell: UITableViewCell {
    // MARK: - UI Components

    private let shadowView: UIView = {
        let view = UIView()
        view.layer.shadowRadius = 4
        view.layer.shadowColor = UIColor.appColor(.secondaryTextColor).cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.backgroundColor = .clear
        return view
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.layer.applyCornerRadiusShadow()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()

    private let sourceNoteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        label.textColor = .label
        return label
    }()

    private let categoryImageContainer: UIView = {
        let view = UIView()
        view.roundedCorner()
        view.backgroundColor = .appColor(.blueBackgroundColor)
        return view
    }()

    private let categoryImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    // MARK: - Properties

    var transaction: UIModel.Transaction? {
        didSet {
            setupData(transaction)
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

        contentView.addSubview(shadowView)
        shadowView.addSubview(containerView)

        shadowView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(6)
        }

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        setupContainerView()
    }

    private func setupContainerView() {
        containerView.addSubview(categoryImageContainer)
        categoryImageContainer.addSubview(categoryImageView)

        categoryImageContainer.snp.makeConstraints { make in
            make.height.width.equalTo(36)
            make.leading.equalToSuperview().offset(12)
            make.top.greaterThanOrEqualToSuperview().offset(12)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        
        containerView.addSubview(categoryLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(sourceNoteLabel)

        categoryLabel.snp.makeConstraints { make in
            make.leading.equalTo(categoryImageContainer.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(12)
            make.trailing.lessThanOrEqualTo(amountLabel.snp.leading).offset(-12)
        }

        amountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }

        sourceNoteLabel.snp.makeConstraints { make in
            make.leading.equalTo(categoryImageContainer.snp.trailing).offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.trailing.lessThanOrEqualToSuperview().offset(-12)
            make.top.greaterThanOrEqualTo(categoryLabel.snp.bottom)
        }
    }

    private func setupData(_ transaction: UIModel.Transaction?) {
        guard let transaction else { return }

        let amount: Double = transaction.amount ?? 0.0
        amountLabel.text = String(format: "£%.2f", amount)
        categoryLabel.text = transaction.category?.displayText
        
        let sourceText = transaction.source?.displayText ?? ""
        let noteText = transaction.note?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        sourceNoteLabel.text = noteText.isEmpty ? sourceText : "\(sourceText) • \(noteText)"

        if let icon = UIImage(systemName: transaction.category?.iconName ?? "") {
            categoryImageView.image = icon
            categoryImageView.tintColor = .black
            categoryImageView.contentMode = .scaleAspectFit

            let ratio = icon.size.width / max(icon.size.height, 1)

            categoryImageView.snp.remakeConstraints { make in
                make.center.equalToSuperview()
                make.width.lessThanOrEqualToSuperview().inset(6)
                make.height.lessThanOrEqualToSuperview().inset(6)

                if ratio >= 1 {
                    make.width.equalToSuperview().inset(6)
                    make.height.equalTo(categoryImageView.snp.width).dividedBy(ratio)
                } else {
                    make.height.equalToSuperview().inset(6)
                    make.width.equalTo(categoryImageView.snp.height).multipliedBy(ratio)
                }
            }
        }
    }
}
