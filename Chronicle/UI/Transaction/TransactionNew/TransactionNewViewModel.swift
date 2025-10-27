import RxCocoa
import RxSwift
import UIKit

class TransactionNewViewModel: BaseViewModel {
    typealias Event = String

    // MARK: - BaseViewModel

    let error = PublishSubject<Error>()
    let event = PublishRelay<String>()
    
    // MARK: - Properties

    private let newTransactionRelay = BehaviorRelay<UIModel.Transaction>(value: .initial())
    var newTransaction: Observable<UIModel.Transaction> { newTransactionRelay.asObservable() }
    var newTransactionDriver: Driver<UIModel.Transaction> { newTransactionRelay.asDriver() }
    
    private let disposeBag = DisposeBag()
    
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

    func setCategory(category: TransactionCategory?) {
        update { $0.category = category }
    }
}
