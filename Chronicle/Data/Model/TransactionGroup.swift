import Foundation

extension UIModel {
    class TransactionGroup: Identifiable {
        var date: Date?
        var transactions: [UIModel.Transaction]

        init(date: Date? = nil, transactions: [UIModel.Transaction] = []) {
            self.date = date
            self.transactions = transactions
        }

        var totalAmount: Double {
            return transactions.reduce(0) { $0 + ($1.amount ?? 0.0) }
        }
    }
}
