import RxCocoa
import RxSwift
import UIKit

class StatsMainViewModel: BaseViewModel {
    typealias Event = String
    
    struct Input {
        let periodSelection: Observable<Period>
        let prevTap: Observable<Void>
        let nextTap: Observable<Void>
        let initialAnchor: Observable<Date>
    }

    struct Output {
        let period: Driver<Period>
        let titleText: Driver<String>
        let anchorDate: Driver<Date>
    }

    let event: Signal<Event>
    let error: Signal<Error>
    
    private let eventRelay = PublishRelay<Event>()
    private let errorRelay = PublishRelay<Error>()
    
    private let calendar: Calendar
    private let locale: Locale
    
    init(calendar: Calendar = {
        var current = Calendar.current
        current.firstWeekday = 2
        return current
    }(), locale: Locale = .current) {
        self.event = eventRelay.asSignal()
        self.error = errorRelay.asSignal()
        self.calendar = calendar
        self.locale = locale
    }
    
    func transform(_ input: Input) -> Output {
        let period = input.periodSelection
            .startWith(.month)
            .distinctUntilChanged()
            .share(replay: 1, scope: .whileConnected)

        let step = Observable.merge(
            input.prevTap.map { -1 },
            input.nextTap.map { +1 }
        )

        let base = input.initialAnchor.startWith(Date())

        struct State: Equatable {
            var period: Period
            var anchor: Date
        }

        let state = Observable
            .combineLatest(period, base.take(1))
            .flatMapLatest { initialPeriod, initialAnchor -> Observable<State> in
                let periodResets = period.map { period in
                    State(period: period, anchor: initialAnchor)
                }

                let shifts = step
                    .withLatestFrom(Observable.combineLatest(period, base.take(1))) { ($0, $1.0, $1.1) }
                    .scan(State(period: initialPeriod, anchor: initialAnchor)) { s, tuple in
                        let (delta, currentPeriod, _) = tuple
                        var next = s
                        next.period = currentPeriod
                        next.anchor = self.shifted(from: s.anchor, period: currentPeriod, delta: delta)
                        return next
                    }

                return Observable.merge(periodResets, shifts)
            }
            .distinctUntilChanged()
            .share(replay: 1, scope: .whileConnected)

        let title = state
            .map { [weak self] state in
                guard let self else { return "" }
                return self.makeTitle(period: state.period, anchor: state.anchor)
            }
            .asDriver(onErrorDriveWith: .empty())

        return Output(
            period: state.map(\.period).asDriver(onErrorDriveWith: .empty()),
            titleText: title,
            anchorDate: state.map(\.anchor).asDriver(onErrorDriveWith: .empty())
        )
    }

    private func shifted(from date: Date, period: Period, delta: Int) -> Date {
        switch period {
        case .day: return calendar.date(byAdding: .day, value: delta, to: date) ?? date
        case .week: return calendar.date(byAdding: .weekOfYear, value: delta, to: date) ?? date
        case .month: return calendar.date(byAdding: .month, value: delta, to: date) ?? date
        case .year: return calendar.date(byAdding: .year, value: delta, to: date) ?? date
        }
    }

    private func makeTitle(period: Period, anchor: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale

        switch period {
        case .day:
            formatter.dateStyle = .medium
            return formatter.string(from: anchor)

        case .week:
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: anchor) else { return "" }
            let start = interval.start
            let end = calendar.date(byAdding: .day, value: 6, to: start) ?? start

            let weekFormatter = DateFormatter(); weekFormatter.calendar = calendar; weekFormatter.locale = locale
            weekFormatter.setLocalizedDateFormatFromTemplate("MMM d")
            let y = DateFormatter(); y.calendar = calendar; y.locale = locale
            y.setLocalizedDateFormatFromTemplate("yyyy")

            let span = "\(weekFormatter.string(from: start)) – \(weekFormatter.string(from: end))"
            let sameYear = calendar.component(.year, from: start) == calendar.component(.year, from: end)
            return sameYear ? "\(span) \(y.string(from: start))"
                : "\(span) (\(y.string(from: start))–\(y.string(from: end)))"

        case .month:
            formatter.setLocalizedDateFormatFromTemplate("LLLL yyyy")
            return formatter.string(from: anchor)

        case .year:
            formatter.setLocalizedDateFormatFromTemplate("yyyy")
            return formatter.string(from: anchor)
        }
    }
}
