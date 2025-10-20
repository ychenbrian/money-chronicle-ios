import RxCocoa
import RxSwift

class TransactionsViewModel: BaseViewModel {
    typealias Event = String

    let error = PublishSubject<Error>()
    let event = PublishRelay<String>()
}
