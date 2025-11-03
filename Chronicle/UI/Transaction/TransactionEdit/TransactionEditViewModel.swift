import RxCocoa
import RxSwift
import UIKit

final class TransactionEditViewModel: BaseViewModel {
    enum Event { case transactionSaved }
    enum Mode: Equatable {
        case create
        case edit(id: String)

        var isEditing: Bool {
            if case .edit = self { return true } else { return false }
        }

        var id: String? {
            if case let .edit(id) = self { return id } else { return nil }
        }
    }

    // MARK: - Outputs

    let transaction: Driver<UIModel.Transaction>
    let isEditing: Bool
    let isSaveEnabled: Driver<Bool>
    let event: Signal<Event>
    let error: Signal<Error>

    // MARK: - Private

    private let repository: TransactionRepositoryType
    private let mode: Mode
    private let formRelay: BehaviorRelay<UIModel.Transaction>
    private let eventRelay = PublishRelay<Event>()
    private let errorRelay = PublishRelay<Error>()
    private let disposeBag = DisposeBag()
    private let bgScheduler: SchedulerType

    // MARK: - Inits

    init(
        repository: TransactionRepositoryType,
        mode: Mode = .create,
        initial: UIModel.Transaction = .initial(),
        bgScheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    ) {
        self.repository = repository
        self.mode = mode
        self.formRelay = .init(value: initial)
        self.bgScheduler = bgScheduler

        self.transaction = formRelay.asDriver()
        self.isEditing = mode.isEditing
        self.isSaveEnabled = formRelay
            .map { transaction in
                (transaction.amount ?? 0) > 0 && transaction.category != nil && transaction.source != nil
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        self.event = eventRelay.asSignal()
        self.error = errorRelay.asSignal()
    }

    convenience init(
        repository: TransactionRepositoryType,
        existing: UIModel.Transaction,
        id: String
    ) {
        self.init(repository: repository, mode: .edit(id: id), initial: existing)
    }

    // MARK: - Update

    func mutate(_ transform: (inout UIModel.Transaction) -> Void) {
        var current = formRelay.value
        transform(&current)
        formRelay.accept(current)
    }

    func set<Value>(_ keyPath: WritableKeyPath<UIModel.Transaction, Value>, _ value: Value) {
        mutate { $0[keyPath: keyPath] = value }
    }

    func setAmount(_ amount: Double) { set(\.amount, amount) }
    func setDate(_ date: Date) { set(\.date, date) }
    func setNote(_ note: String?) { set(\.note, note) }
    func setCategory(_ category: TransactionCategory?) { set(\.category, category) }
    func setSource(_ source: TransactionSource?) { set(\.source, source) }

    // MARK: - Save

    @discardableResult
    func save() -> Completable {
        let uiModel = formRelay.value

        let work = Completable.create { [repository, mode] observer in
            do {
                switch mode {
                case .create:
                    try repository.add(uiModel.toDBModel())
                case .edit(let id):
                    try repository.update(id: id) { db in
                        let dbModel = uiModel.toDBModel()
                        db.amount = dbModel.amount
                        db.date = dbModel.date
                        db.note = dbModel.note
                        db.category = dbModel.category
                        db.source = dbModel.source
                    }
                }
                observer(.completed)
            } catch {
                observer(.error(error))
            }
            return Disposables.create()
        }

        work
            .subscribe(on: bgScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onCompleted: { [weak self] in
                    guard let self = self else { return }
                    self.eventRelay.accept(.transactionSaved)
                    if case .create = self.mode { self.formRelay.accept(.initial()) }
                },
                onError: { [weak self] in self?.errorRelay.accept($0) }
            )
            .disposed(by: disposeBag)

        return work
    }
}
