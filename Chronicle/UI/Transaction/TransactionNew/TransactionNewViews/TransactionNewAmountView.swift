import SnapKit
import UIKit

@MainActor
final class TransactionNewAmountView: UIView {
    struct Config {
        var hapticsEnabled: Bool = true
        var minimumFractionDigits: Int = 0
        var maximumFractionDigits: Int = 2
    }

    var onAmountChanged: ((Decimal) -> Void)?
    var config = Config() {
        didSet {
            numberFormatter.minimumFractionDigits = config.minimumFractionDigits
            numberFormatter.maximumFractionDigits = config.maximumFractionDigits
            updateDecimalButtonEnabledState()
        }
    }

    var locale: Locale = .current {
        didSet {
            numberFormatter.locale = locale
            decSep = numberFormatter.decimalSeparator ?? "."
            rebuildKeypad()
            setAmount(currentDecimal())
        }
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
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleKeypad)))
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let keypadContainer = UIStackView()
    private var decimalButton: UIButton?
    private var backspaceButton: UIButton?

    // MARK: - State

    private lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = config.minimumFractionDigits
        formatter.maximumFractionDigits = config.maximumFractionDigits
        return formatter
    }()
    
    // MARK: - Properties

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
        addSubview(keypadContainer)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(10)
            make.height.greaterThanOrEqualTo(24)
        }
        amountLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-24)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }

        keypadContainer.axis = .vertical
        keypadContainer.spacing = 8
        keypadContainer.distribution = .fillEqually
        rebuildKeypad()

        keypadContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    private func rebuildKeypad() {
        keypadContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }

        func row(_ titles: [String]) -> UIStackView {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 8
            stackView.distribution = .fillEqually
            titles.forEach { t in stackView.addArrangedSubview(makeKeyButton(t)) }
            return stackView
        }

        keypadContainer.addArrangedSubview(row(["1", "2", "3"]))
        keypadContainer.addArrangedSubview(row(["4", "5", "6"]))
        keypadContainer.addArrangedSubview(row(["7", "8", "9"]))
        let dec = makeKeyButton(decSep)
        decimalButton = dec
        let zero = makeKeyButton("0")
        let back = makeKeyButton("⌫")
        backspaceButton = back

        let lastRow = UIStackView(arrangedSubviews: [dec, zero, back])
        lastRow.axis = .horizontal
        lastRow.spacing = 8
        lastRow.distribution = .fillEqually
        keypadContainer.addArrangedSubview(lastRow)

        updateDecimalButtonEnabledState()
    }

    private func makeKeyButton(_ title: String) -> UIButton {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .secondarySystemBackground
        config.baseForegroundColor = .label
        config.cornerStyle = .large
        config.title = title
        button.configuration = config

        let constraint = button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        constraint.priority = .defaultHigh
        constraint.isActive = true

        button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
        button.accessibilityLabel = "Key \(title)"
        return button
    }

    private func updateDecimalButtonEnabledState() {
        let enabled = config.maximumFractionDigits > 0
        decimalButton?.isEnabled = enabled
        decimalButton?.alpha = enabled ? 1.0 : 0.5
    }

    // MARK: - Actions

    @objc private func toggleKeypad() { setKeypadVisible(keypadContainer.isHidden) }

    @objc private func keyTapped(_ sender: UIButton) {
        let title = sender.title(for: .normal) ?? sender.configuration?.title ?? sender.currentTitle ?? ""
        guard !title.isEmpty else { return }

        switch title {
        case "⌫":
            handleBackspace()
        case decSep where config.maximumFractionDigits > 0:
            insertDecimalSeparator()
        default:
            insertDigit(title)
        }
        provideTapHaptic()
        notifyIfValid()
    }

    // MARK: - Private

    private func insertDigit(_ digit: String) {
        guard digit.allSatisfy({ $0.isNumber }) else { return }

        if amountText == "0" {
            amountText = digit
            return
        }

        if let sep = amountText.firstIndex(of: Character(decSep)) {
            let fractionalCount = amountText[amountText.index(after: sep)...].count
            if fractionalCount >= config.maximumFractionDigits { return }
        }

        amountText.append(digit)
    }

    private func insertDecimalSeparator() {
        guard config.maximumFractionDigits > 0 else { return }
        if amountText.contains(decSep) { return }
        amountText.append(decSep)
    }

    private func handleBackspace() {
        guard !amountText.isEmpty else { return }
        amountText.removeLast()
        if amountText.isEmpty || amountText == decSep {
            amountText = "0"
        }
    }

    private func notifyIfValid() {
        if let value = currentDecimal() {
            onAmountChanged?(value)
        }
        amountLabel.accessibilityValue = amountText
    }

    private func currentDecimal() -> Decimal? {
        numberFormatter.number(from: amountText)?.decimalValue
    }

    // MARK: - Public

    func setAmount(_ value: Decimal?) {
        guard let value else { amountText = "0"; return }
        amountText = numberFormatter.string(from: value as NSDecimalNumber) ?? "0"
    }

    func getAmount() -> Decimal? { currentDecimal() }

    func setKeypadVisible(_ visible: Bool) {
        keypadContainer.isHidden = !visible
        if visible { provideOpenHaptic() }
    }

    // MARK: - Haptics

    private func provideOpenHaptic() {
        guard config.hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func provideTapHaptic() {
        guard config.hapticsEnabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
