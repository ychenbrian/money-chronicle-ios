import RxCocoa
import RxSwift

class SettingsViewModel: BaseViewModel {
    typealias Event = String

    let error = PublishSubject<Error>()
    let event = PublishRelay<String>()
}
