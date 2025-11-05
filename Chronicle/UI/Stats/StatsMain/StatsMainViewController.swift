import RxCocoa
import RxSwift
import SnapKit
import UIKit

class StatsMainViewController: BaseViewController {
    // MARK: - UI Components

    private let scrollView = UIScrollView()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    private let titleView = StatsMainTitleView()
    
    // MARK: - Properties

    private var viewModel: StatsMainViewModel!
    private let disposeBag = DisposeBag()
    private let prevRelay = PublishRelay<Void>()
    private let nextRelay = PublishRelay<Void>()

    // MARK: - Lifecycle
    
    convenience init(viewModel: StatsMainViewModel) {
        self.init()
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup

    private func setupView() {
        self.title = String(localized: "stats.main.title")
        self.view.backgroundColor = .systemBackground

        self.view.addSubview(scrollView)
        scrollView.keyboardDismissMode = .interactive
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }

        scrollView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        setupTitleView()
        mainStackView.addArrangedSubview(titleView)
    }
    
    private func setupTitleView() {
        titleView.onPrev = { [weak self] in self?.prevRelay.accept(()) }
        titleView.onNext = { [weak self] in self?.nextRelay.accept(()) }

        titleView.onPeriodChange = nil

        let input = StatsMainViewModel.Input(
            periodSelection: titleView.segmented.rx.selectedSegmentIndex
                .compactMap(Period.init(rawValue:))
                .asObservable(),
            prevTap: prevRelay.asObservable(),
            nextTap: nextRelay.asObservable(),
            initialAnchor: .just(Date())
        )

        let output = viewModel.transform(input)

        output.titleText
            .drive(with: self) { me, text in
                me.titleView.setPeriodTitle(text)
            }
            .disposed(by: disposeBag)

        output.period
            .map(\.rawValue)
            .drive(titleView.segmented.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        output.period
            .drive(onNext: { _ in UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .disposed(by: disposeBag)
    }
}
