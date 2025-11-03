import SnapKit
import UIKit

class TransactionEditNoteView: UIView {
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "transaction.new.note.title")
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 15)
        textView.textColor = .label
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 28)
        textView.backgroundColor = .clear
        return textView
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "xmark.circle.fill")
        button.setImage(image, for: .normal)
        button.tintColor = .tertiaryLabel
        button.isHidden = true
        return button
    }()
    
    // MARK: - Property
    
    var onNoteChanged: ((String) -> Void)?
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupActions()
        textView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupActions()
        textView.delegate = self
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        addSubview(titleLabel)
        addSubview(containerView)
        containerView.addSubview(textView)
        containerView.addSubview(clearButton)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(4)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview()
        }
        
        textView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(clearButton.snp.leading).offset(-4)
        }
        
        clearButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(20)
        }
    }
    
    private func setupActions() {
        clearButton.addTarget(self, action: #selector(clearText), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func clearText() {
        textView.text = ""
        clearButton.isHidden = true
        onNoteChanged?("")
    }
    
    // MARK: - Public
    
    func setNote(_ note: String) {
        textView.text = note
        clearButton.isHidden = note.isEmpty
    }
    
    func getNote() -> String {
        textView.text
    }
}

// MARK: - UITextViewDelegate

extension TransactionEditNoteView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        clearButton.isHidden = textView.text.isEmpty
        onNoteChanged?(textView.text)
    }
}
