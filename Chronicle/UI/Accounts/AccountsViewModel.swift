import RxCocoa
import RxSwift

class AccountsViewModel: BaseViewModel {
    typealias Event = String

    let error = PublishSubject<Error>()
    let event = PublishRelay<String>()
    let accounts: BehaviorRelay<[Account]> = BehaviorRelay(value: [])
}
