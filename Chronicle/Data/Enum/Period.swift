import UIKit

enum Period: Int, CaseIterable {
    case day, week, month, year
    var title: String {
        switch self {
        case .day: return String(localized: "period.day")
        case .week: return String(localized: "period.week")
        case .month: return String(localized: "period.month")
        case .year: return String(localized: "period.year")
        }
    }
}
