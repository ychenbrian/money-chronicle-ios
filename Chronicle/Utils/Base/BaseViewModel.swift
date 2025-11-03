import RxCocoa
import RxSwift

protocol BaseViewModel {
    var error: Signal<Error> { get }
}

protocol EventTransmitter: BaseViewModel {
    associatedtype Event
    var event: Signal<Event> { get }
}
