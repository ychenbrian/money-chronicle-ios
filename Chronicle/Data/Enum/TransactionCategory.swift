import Foundation

enum TransactionCategory: String, CaseIterable, Codable {
    case foodAndDrink = "food_and_drink"
    case groceries
    case transportation
    case housing
    case utilities
    case entertainment
    case shopping
    case clothing
    case health
    case education
    case travel
    case gifts
    case subscriptions
    case personalCare = "personal_care"
    case others

    var displayText: String {
        let key = "transaction.category.\(rawValue)"
        return NSLocalizedString(key, comment: "")
    }

    var iconName: String {
        switch self {
        case .foodAndDrink: return "fork.knife"
        case .groceries: return "cart"
        case .transportation: return "car"
        case .housing: return "house"
        case .utilities: return "bolt"
        case .entertainment: return "gamecontroller"
        case .shopping: return "bag"
        case .clothing: return "tshirt"
        case .health: return "heart"
        case .education: return "book"
        case .travel: return "airplane"
        case .gifts: return "gift"
        case .subscriptions: return "tv"
        case .personalCare: return "person.crop.circle"
        case .others: return "ellipsis"
        }
    }

    static func from(_ rawValue: String?) -> TransactionCategory {
        guard let rawValue, let category = TransactionCategory(rawValue: rawValue) else {
            return .others
        }
        return category
    }
}
