import SnapKit
import UIKit

class TransactionEmptyCell: UITableViewCell {
    // MARK: - UI Components
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()

    private let moneyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "banknote")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "No transactions yet")
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .appColor(.secondaryTextColor)
        label.textAlignment = .center
        return label
    }()
    
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
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(moneyImageView)
        stackView.addArrangedSubview(titleLabel)

        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualTo(contentView).offset(12)
            make.trailing.lessThanOrEqualTo(contentView).offset(-12)
            make.top.greaterThanOrEqualTo(contentView).offset(12)
            make.bottom.lessThanOrEqualTo(contentView).offset(-12)
        }
    }
}
