import SnapKit
import UIKit

final class TransactionNewSourceView: UIView {
    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "transaction.new.source.title")
        label.font = .systemFont(ofSize: 16, weight: .regular)
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

    private(set) var selectedSource: TransactionSource = .debitCard
    var onSourceChanged: ((TransactionSource) -> Void)?

    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setSource(selectedSource)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setSource(selectedSource)
    }

    // MARK: - Setup

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
        let actions = TransactionSource.allCases.map { source in
            UIAction(title: source.displayText,
                     image: UIImage(systemName: source.iconName)) { [weak self] _ in
                self?.setSource(source)
                if let selected = self?.selectedSource { self?.onSourceChanged?(selected) }
            }
        }
        let menu = UIMenu(title: "", children: actions)
        selectButton.menu = menu
        selectButton.showsMenuAsPrimaryAction = true
    }

    private func updateButtonAppearance() {
        let title = selectedSource.displayText
        let image = UIImage(systemName: selectedSource.iconName)
        var config = selectButton.configuration ?? .plain()
        config.title = title
        config.image = image
        config.imagePlacement = .leading
        config.imagePadding = 6
        selectButton.configuration = config
    }

    // MARK: - Public

    func setSource(_ source: TransactionSource) {
        selectedSource = source
        updateButtonAppearance()
    }

    func getSource() -> TransactionSource {
        selectedSource
    }
}
