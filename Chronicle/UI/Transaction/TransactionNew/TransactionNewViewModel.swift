import RxCocoa
import RxSwift
import UIKit

class TransactionNewViewModel: BaseViewModel {
    typealias Event = String

    // MARK: - BaseViewModel

    let error = PublishSubject<Error>()
    let event = PublishRelay<String>()
}
