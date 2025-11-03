import SnapKit
import UIKit

@MainActor
final class TransactionEditDigitPadView: UIView {
    // MARK: - Config

    struct Config {
        var decimalSeparator: String = Locale.current.decimalSeparator ?? "."
        var hapticsEnabled: Bool = true
        var keyHeight: CGFloat = 44
    }

    var padConfig = Config() { didSet { rebuild() } }

    // MARK: - Callback
    
    var onDigit: ((Int) -> Void)?
    var onDecimal: (() -> Void)?
    var onBackspace: (() -> Void)?
    var onClearAll: (() -> Void)?

    // MARK: - UI Components

    private let container = UIStackView()
    private weak var decimalButton: UIButton?
    private weak var backspaceButton: UIButton?

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        rebuild()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        rebuild()
    }

    // MARK: - Setup

    private func setupView() {
        container.axis = .vertical
        container.spacing = 8
        container.distribution = .fillEqually
        addSubview(container)
        container.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }

    private func rebuild() {
        container.arrangedSubviews.forEach { $0.removeFromSuperview() }

        func row(_ views: [UIView]) -> UIStackView {
            let r = UIStackView(arrangedSubviews: views)
            r.axis = .horizontal
            r.spacing = 8
            r.distribution = .fillEqually
            return r
        }

        container.addArrangedSubview(row(["1", "2", "3"].map(makeKey)))
        container.addArrangedSubview(row(["4", "5", "6"].map(makeKey)))
        container.addArrangedSubview(row(["7", "8", "9"].map(makeKey)))

        let dec = makeKey(padConfig.decimalSeparator)
        decimalButton = dec
        let zero = makeKey("0")
        let backButton = makeBackspaceKey()
        backspaceButton = backButton

        let last = row([dec, zero, backButton])
        container.addArrangedSubview(last)
    }

    private func makeKey(_ title: String) -> UIButton {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .secondarySystemBackground
        config.baseForegroundColor = .label
        config.cornerStyle = .large
        config.title = title
        button.configuration = config

        let constraint = button.heightAnchor.constraint(greaterThanOrEqualToConstant: padConfig.keyHeight)
        constraint.priority = .defaultHigh
        constraint.isActive = true

        button.addTarget(self, action: #selector(tapKey(_:)), for: .touchUpInside)
        return button
    }

    private func makeBackspaceKey() -> UIButton {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .secondarySystemBackground
        config.baseForegroundColor = .label
        config.cornerStyle = .medium
        config.image = UIImage(systemName: "delete.left")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        button.configuration = config

        let constraint = button.heightAnchor.constraint(greaterThanOrEqualToConstant: padConfig.keyHeight)
        constraint.priority = .defaultHigh
        constraint.isActive = true

        button.addTarget(self, action: #selector(tapBackspace(_:)), for: .touchUpInside)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressBackspace(_:)))
        longPress.minimumPressDuration = 0.5
        button.addGestureRecognizer(longPress)

        return button
    }

    // MARK: - Actions

    @objc private func tapKey(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) ?? sender.configuration?.title, !title.isEmpty else { return }

        if title == padConfig.decimalSeparator {
            onDecimal?()
            feedbackTap()
        } else if let digit = Int(title) {
            onDigit?(digit)
            feedbackTap()
        }
    }

    @objc private func tapBackspace(_ sender: UIButton) {
        onBackspace?()
        feedbackTap()
    }

    @objc private func longPressBackspace(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        onClearAll?()
        feedbackImpact()
    }

    // MARK: - Haptics

    private func feedbackTap() {
        guard padConfig.hapticsEnabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    private func feedbackImpact() {
        guard padConfig.hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
