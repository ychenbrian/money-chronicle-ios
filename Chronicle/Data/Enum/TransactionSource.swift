import Foundation

import Foundation

enum TransactionSource: String, CaseIterable, Codable {
    case cash
    case accounts
    case debitCard = "debit_card"
    case creditCard = "credit_card"

    var displayText: String {
        let key = "transaction.source.\(rawValue)"
        return NSLocalizedString(key, comment: "")
    }

    var iconName: String {
        switch self {
        case .cash: return "banknote"
        case .accounts: return "building.2"
        case .debitCard: return "creditcard"
        case .creditCard: return "creditcard.fill"
        }
    }

    static func from(_ rawValue: String?) -> TransactionSource {
        guard let rawValue, let source = TransactionSource(rawValue: rawValue) else {
            return .cash
        }
        return source
    }
}
