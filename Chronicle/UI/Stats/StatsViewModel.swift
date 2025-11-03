import RxCocoa
import RxSwift
import UIKit

class StatsViewModel: BaseViewModel {
    typealias Event = String

    let event: Signal<Event>
    let error: Signal<Error>
    
    private let eventRelay = PublishRelay<Event>()
    private let errorRelay = PublishRelay<Error>()
    
    init() {
        self.event = eventRelay.asSignal()
        self.error = errorRelay.asSignal()
    }
}
