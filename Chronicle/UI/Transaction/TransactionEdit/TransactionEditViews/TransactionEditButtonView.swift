import SnapKit
import UIKit

class TransactionEditButtonView: UIView {
    // MARK: - UI Components
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = String(localized: "transaction.new.save.title")
        config.buttonSize = .large
        config.cornerStyle = .large
        config.contentInsets = .init(top: 12, leading: 20, bottom: 12, trailing: 20)
        button.configuration = config
        return button
    }()
    
    // MARK: - Property
    
    var onSave: (() -> Void)?
    
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
        saveButton.addTarget(self, action: #selector(onSaveButtonTapped), for: .touchUpInside)
        addSubview(saveButton)
        
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalToSuperview().offset(48)
            make.bottom.equalToSuperview().offset(-32)
            make.height.greaterThanOrEqualTo(48)
        }
    }
    
    // MARK: - Actions
    
    @objc private func onSaveButtonTapped() {
        onSave?()
    }
    
    func setEnabled(_ enabled: Bool) {}
}
