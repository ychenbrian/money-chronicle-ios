import SnapKit
import UIKit

final class StatsMainTitleView: UIView {
    // MARK: - Callbacks

    var onPeriodChange: ((Period) -> Void)?
    var onPrev: (() -> Void)?
    var onNext: (() -> Void)?

    // MARK: - UI Components
    
    private let periodContainerView = UIView()

    private let prevButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        return button
    }()

    private let periodLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()

    let segmented: UISegmentedControl = {
        let control = UISegmentedControl(items: Period.allCases.map { $0.title })
        control.selectedSegmentIndex = Period.month.rawValue
        control.setContentCompressionResistancePriority(.required, for: .vertical)
        return control
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Public

    func setPeriod(_ period: Period) {
        segmented.selectedSegmentIndex = period.rawValue
    }

    func setPeriodTitle(_ text: String) {
        periodLabel.text = text
    }

    // MARK: - Private

    private func setupView() {
        self.backgroundColor = .clear
        
        self.addSubview(periodContainerView)
        self.addSubview(segmented)

        periodContainerView.addSubview(prevButton)
        periodContainerView.addSubview(periodLabel)
        periodContainerView.addSubview(nextButton)
        
        periodContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(12)
        }

        prevButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.height.equalTo(32)
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
        }
        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.width.height.equalTo(32)
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
        }
        
        periodLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(prevButton.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(nextButton.snp.leading).offset(-8)
            make.center.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        segmented.snp.makeConstraints { make in
            make.top.equalTo(prevButton.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().offset(-8)
        }

        segmented.addTarget(self, action: #selector(segmentedChanged), for: .valueChanged)
        prevButton.addAction(UIAction { [weak self] _ in self?.onPrev?() }, for: .touchUpInside)
        nextButton.addAction(UIAction { [weak self] _ in self?.onNext?() }, for: .touchUpInside)

        periodLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    // MARK: - Action
    
    @objc private func segmentedChanged() {
        guard let period = Period(rawValue: segmented.selectedSegmentIndex) else { return }
        onPeriodChange?(period)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
