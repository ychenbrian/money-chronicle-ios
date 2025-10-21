import Foundation
import RxCocoa
import RxSwift

class TransactionsViewModel: BaseViewModel {
    typealias Event = String

    // MARK: - BaseViewModel

    let error = PublishSubject<Error>()
    let event = PublishRelay<String>()

    // MARK: - Properties

    private let transGroupsRelay = BehaviorRelay<[UIModel.TransactionGroup]>(value: [])
    var transGroups: Observable<[UIModel.TransactionGroup]> {
        transGroupsRelay.asObservable()
    }

    // MARK: - Public actions

    func updateTransactions(with newTransactions: [UIModel.Transaction]) {
        let groupedDict = Dictionary(grouping: newTransactions) { transaction -> Date in
            let date = transaction.date ?? Date()
            return Calendar.current.startOfDay(for: date)
        }

        let sortedKeys = groupedDict.keys.sorted(by: >)

        let groups = sortedKeys.map { key -> UIModel.TransactionGroup in
            let transactions = groupedDict[key] ?? []
            let sortedTransactions = transactions.sorted { a, b -> Bool in
                let dateA = a.date ?? Date.distantPast
                let dateB = b.date ?? Date.distantPast
                return dateA > dateB
            }
            return UIModel.TransactionGroup(date: key, transactions: sortedTransactions)
        }

        transGroupsRelay.accept(groups)
    }

    func addTransaction(_ transaction: UIModel.Transaction) {
        var currentGroups = transGroupsRelay.value

        let transData = Calendar.current.startOfDay(for: transaction.date ?? Date())
        if let index = currentGroups.firstIndex(where: { Calendar.current.isDate($0.date ?? Date.distantPast, inSameDayAs: transData) }) {
            let group = currentGroups[index]
            group.transactions.append(transaction)
            group.transactions.sort { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }
            currentGroups[index] = group
        } else {
            let newGroup = UIModel.TransactionGroup(date: transData, transactions: [transaction])
            var inserted = false
            for (i, g) in currentGroups.enumerated() {
                if let gDate = g.date, transData > gDate {
                    currentGroups.insert(newGroup, at: i)
                    inserted = true
                    break
                }
            }
            if !inserted {
                currentGroups.append(newGroup)
            }
        }

        transGroupsRelay.accept(currentGroups)
    }

    func clearAll() {
        transGroupsRelay.accept([])
    }

    // MARK: - Mock data

    func loadMockTransactions() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let dayBeforeYesterday = Calendar.current.date(byAdding: .day, value: -2, to: Date())

        let mock: [UIModel.Transaction] = [
            UIModel.Transaction(id: "1", title: "Lunch", amount: 12.5, date: Date(), source: TransactionSource.allCases.randomElement()!, category: TransactionCategory.allCases.randomElement()!, note: ""),
            UIModel.Transaction(id: "2", title: "Bus", amount: 2.5, date: yesterday, source: TransactionSource.allCases.randomElement()!, category: TransactionCategory.allCases.randomElement()!, note: ""),
            UIModel.Transaction(id: "3", title: "Groceries", amount: 35.0, date: Date(), source: TransactionSource.allCases.randomElement()!, category: TransactionCategory.allCases.randomElement()!, note: ""),
            UIModel.Transaction(id: "4", title: "Dinner", amount: 12.5, date: dayBeforeYesterday, source: TransactionSource.allCases.randomElement()!, category: TransactionCategory.allCases.randomElement()!, note: ""),
            UIModel.Transaction(id: "5", title: "Education", amount: 2.5, date: dayBeforeYesterday, source: TransactionSource.allCases.randomElement()!, category: TransactionCategory.allCases.randomElement()!, note: ""),
            UIModel.Transaction(id: "6", title: "Groceries", amount: 35.0, date: Date(), source: TransactionSource.allCases.randomElement()!, category: TransactionCategory.allCases.randomElement()!, note: ""),
        ]
        updateTransactions(with: mock)
    }
}
