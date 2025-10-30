import RxCocoa
import RxSwift
import UIKit

class TransactionNewViewModel: BaseViewModel {
    enum Event { case transactionSaved }

    // MARK: - BaseViewModel

    let error = PublishSubject<Error>()
    let event = PublishRelay<Event>()
    
    // MARK: - Properties

    private let repository: TransactionRepositoryType
    
    private let newTransactionRelay = BehaviorRelay<UIModel.Transaction>(value: .initial())
    var newTransaction: Observable<UIModel.Transaction> { newTransactionRelay.asObservable() }
    var newTransactionDriver: Driver<UIModel.Transaction> { newTransactionRelay.asDriver() }
    
    private let disposeBag = DisposeBag()
    
    init(repository: TransactionRepositoryType) {
        self.repository = repository
    }
    
    // MARK: - Update helpers

    /// Generic updater
    func update(_ transform: (inout UIModel.Transaction) -> Void) {
        var current = newTransactionRelay.value
        transform(&current)
        newTransactionRelay.accept(current)
    }
    
    func setAmount(_ amount: Double) {
        update { $0.amount = amount }
    }

    func setDate(_ date: Date) {
        update { $0.date = date }
    }

    func setNote(_ note: String?) {
        update { $0.note = note }
    }

    func setCategory(_ category: TransactionCategory?) {
        update { $0.category = category }
    }
    
    func setSource(_ source: TransactionSource?) {
        update { $0.source = source }
    }

    func saveTransaction() {
        let uiModel = newTransactionRelay.value
        do {
            try repository.add(uiModel.toDBModel())
            event.accept(.transactionSaved)
            newTransactionRelay.accept(.initial())
        } catch {
            self.error.onNext(error)
        }
    }
}
