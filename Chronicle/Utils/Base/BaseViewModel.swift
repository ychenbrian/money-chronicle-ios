import RxCocoa
import RxSwift

protocol BaseViewModel {
    var error: PublishSubject<Error> { get }
}

protocol EventTransmitter: BaseViewModel {
    associatedtype Event
    var event: PublishRelay<Event> { get }
}
