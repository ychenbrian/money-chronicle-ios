import SnapKit
import UIKit

@MainActor
final class TransactionNewAmountView: UIView {
    // MARK: - Config

    struct Config {
        var minimumFractionDigits: Int = 0
        var maximumFractionDigits: Int = 2
    }

    var onAmountChanged: ((Decimal) -> Void)?
    var onRequestInput: (() -> Void)?

    var config = Config() {
        didSet {
            numberFormatter.minimumFractionDigits = config.minimumFractionDigits
            numberFormatter.maximumFractionDigits = config.maximumFractionDigits
            setAmount(currentDecimal())
        }
    }

    var locale: Locale = .current {
        didSet {
            numberFormatter.locale = locale
            decSep = numberFormatter.decimalSeparator ?? "."
            setAmount(currentDecimal())
        }
    }

    enum InputAction {
        case digit(Int)
        case decimal
        case backspace
        case clearAll
    }

    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "transaction.new.amount.title")
        label.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 16, weight: .regular))
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textAlignment = .right
        label.font = UIFontMetrics(forTextStyle: .title3).scaledFont(for: .systemFont(ofSize: 20, weight: .semibold))
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAmount)))
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    // MARK: - Properties

    private lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = config.minimumFractionDigits
        formatter.maximumFractionDigits = config.maximumFractionDigits
        return formatter
    }()

    private var decSep: String = Locale.current.decimalSeparator ?? "."
    private var amountText: String = "0" { didSet { amountLabel.text = amountText } }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - Setup

    private func setupViews() {
        addSubview(titleLabel)
        addSubview(amountLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.greaterThanOrEqualToSuperview().offset(4)
            make.bottom.lessThanOrEqualToSuperview().offset(-4)
            make.centerY.equalToSuperview()
            make.height.greaterThanOrEqualTo(24)
        }

        amountLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-24)
            make.top.greaterThanOrEqualToSuperview().offset(4)
            make.bottom.lessThanOrEqualToSuperview().offset(-4)
            make.centerY.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    // MARK: - Actions

    @objc private func didTapAmount() {
        onRequestInput?()
    }

    // MARK: - Private

    private func insertDigit(_ digit: String) {
        guard digit.allSatisfy({ $0.isNumber }) else { return }

        if amountText == "0" {
            amountText = digit
            notifyIfValid()
            return
        }

        if let sep = amountText.firstIndex(of: Character(decSep)) {
            let fractionalCount = amountText[amountText.index(after: sep)...].count
            if fractionalCount >= config.maximumFractionDigits { return }
        }

        amountText.append(digit)
        notifyIfValid()
    }

    private func insertDecimalSeparator() {
        guard config.maximumFractionDigits > 0 else { return }
        if amountText.contains(decSep) { return }
        amountText.append(decSep)
        notifyIfValid()
    }

    private func handleBackspace() {
        guard !amountText.isEmpty else { return }
        amountText.removeLast()
        if amountText.isEmpty || amountText == decSep { amountText = "0" }
        notifyIfValid()
    }

    private func notifyIfValid() {
        if let value = currentDecimal() { onAmountChanged?(value) }
        amountLabel.accessibilityValue = amountText
    }

    private func currentDecimal() -> Decimal? {
        numberFormatter.number(from: amountText)?.decimalValue
    }

    // MARK: - Public
    
    func apply(_ action: InputAction) {
        switch action {
        case .digit(let d):
            insertDigit(String(d))
        case .decimal:
            insertDecimalSeparator()
        case .backspace:
            handleBackspace()
        case .clearAll:
            amountText = "0"
            notifyIfValid()
        }
    }

    func setAmount(_ value: Decimal?) {
        guard let value else { amountText = "0"; return }
        amountText = numberFormatter.string(from: value as NSDecimalNumber) ?? "0"
        notifyIfValid()
    }

    func getAmount() -> Double { NSDecimalNumber(decimal: currentDecimal() ?? 0.0).doubleValue }
}
