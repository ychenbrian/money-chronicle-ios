import SnapKit
import UIKit

class TransactionEditCategoryView: UIView {
    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "transaction.new.category.title")
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()

    private let selectButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .init(top: 6, leading: 10, bottom: 6, trailing: 10)
        config.imagePlacement = .leading
        config.imagePadding = 6
        let button = UIButton(configuration: config)
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    // MARK: - Property
    
    private(set) var selectedCategory: TransactionCategory = .foodAndDrink
    var onCategoryChanged: ((TransactionCategory) -> Void)?

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setCategory(selectedCategory)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setCategory(selectedCategory)
    }

    // MARK: Setup

    private func setupViews() {
        addSubview(titleLabel)
        addSubview(selectButton)

        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        selectButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }

        selectButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }

        rebuildMenu()
    }

    private func rebuildMenu() {
        let actions = TransactionCategory.allCases.map { category in
            UIAction(title: category.displayText, image: UIImage(systemName: category.iconName)) { [weak self] _ in
                self?.setCategory(category)
                if let selected = self?.selectedCategory {
                    self?.onCategoryChanged?(selected)
                }
            }
        }
        let menu = UIMenu(title: "", children: actions)
        selectButton.menu = menu
        selectButton.showsMenuAsPrimaryAction = true
    }

    private func updateButtonAppearance() {
        let title = selectedCategory.displayText
        let image = UIImage(systemName: selectedCategory.iconName)
        var config = selectButton.configuration ?? .plain()
        config.title = title
        config.image = image
        config.imagePlacement = .leading
        config.imagePadding = 6
        selectButton.configuration = config
    }

    // MARK: Public

    func setCategory(_ category: TransactionCategory) {
        selectedCategory = category
        updateButtonAppearance()
    }

    func getCategory() -> TransactionCategory {
        selectedCategory
    }
}
