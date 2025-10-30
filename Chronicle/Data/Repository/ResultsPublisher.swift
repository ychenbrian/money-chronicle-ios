import Combine
import RealmSwift
internal import Realm

final class ResultsPublisher<Element: Object>: Publisher {
    typealias Output = [Element]
    typealias Failure = Never

    private let results: Results<Element>

    init(results: Results<Element>) {
        self.results = results
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = ResultsSubscription(subscriber: subscriber, results: results)
        subscriber.receive(subscription: subscription)
    }

    private final class ResultsSubscription<S: Subscriber>: Subscription where S.Input == [Element], S.Failure == Never {
        private var subscriber: S?
        private var token: NotificationToken?
        private let results: Results<Element>

        init(subscriber: S, results: Results<Element>) {
            self.subscriber = subscriber
            self.results = results
            
            _ = subscriber.receive(Array(results))
            
            token = results.observe { [weak self] _ in
                guard let self = self else { return }
                _ = self.subscriber?.receive(Array(self.results))
            }
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            token?.invalidate()
            token = nil
            subscriber = nil
        }
    }
}
