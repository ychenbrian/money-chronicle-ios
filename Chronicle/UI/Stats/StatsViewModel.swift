import RxCocoa
import RxSwift
import UIKit

class StatsViewModel: BaseViewModel {
    typealias Event = String

    let error = PublishSubject<Error>()
    let event = PublishRelay<String>()
}
