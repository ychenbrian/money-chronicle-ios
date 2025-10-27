import Foundation

extension UIModel.Transaction {
    static func initial() -> UIModel.Transaction {
        return .init(title: nil, amount: nil, date: nil, source: nil, category: nil, note: nil)
    }
}
