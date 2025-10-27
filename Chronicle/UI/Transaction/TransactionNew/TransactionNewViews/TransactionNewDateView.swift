import SnapKit
import UIKit

class TransactionNewDateView: UIView {    
    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "transaction.new.date.title")
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .compact
        datePicker.minuteInterval = 5
        datePicker.addTarget(self, action: #selector(dateDidChange(_:)), for: .valueChanged)
        return datePicker
    }()
    
    // MARK: - Property
    
    var onDateChanged: ((Date) -> Void)?
    
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
        addSubview(datePicker)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        datePicker.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    // MARK: - Actions

    @objc private func dateDidChange(_ sender: UIDatePicker) {
        onDateChanged?(sender.date)
    }
    
    // MARK: - Public

    func setDate(_ date: Date) {
        datePicker.date = date
    }
    
    func getDate() -> Date {
        datePicker.date
    }
}
