import Foundation
import RealmSwift

extension DBModel {
    @objc(DBTransaction)
    class Transaction: Object {
        @Persisted(primaryKey: true) var id: String = UUID().uuidString
        @Persisted var title: String = ""
        @Persisted var amount: Double = 0.0
        @Persisted var date: Date = .init()
        @Persisted var source: String = ""
        @Persisted var category: String = ""
        @Persisted var note: String = ""
    }
}

extension APIModel {
    struct Transaction: Codable, Equatable {
        var id: String?
        var title: String?
        var amount: Double?
        var date: Date?
        var source: TransactionSource?
        var category: TransactionCategory?
        var note: String?
    }
}

extension UIModel {
    class Transaction: Identifiable {
        var id: String?
        var title: String?
        var amount: Double?
        var date: Date?
        var source: TransactionSource?
        var category: TransactionCategory?
        var note: String?

        init(id: String = UUID().uuidString, title: String?, amount: Double?, date: Date?, source: TransactionSource?, category: TransactionCategory?, note: String?) {
            self.id = id
            self.title = title
            self.amount = amount
            self.date = date
            self.source = source
            self.category = category
            self.note = note
        }

        init(_ dbTransaction: DBModel.Transaction) {
            id = dbTransaction.id
            title = dbTransaction.title
            amount = dbTransaction.amount
            date = dbTransaction.date
            source = TransactionSource.from(dbTransaction.source)
            category = TransactionCategory.from(dbTransaction.category)
            note = dbTransaction.note
        }
        
        init(_ apiTransaction: APIModel.Transaction) {
            id = apiTransaction.id
            title = apiTransaction.title
            amount = apiTransaction.amount
            date = apiTransaction.date
            source = apiTransaction.source
            category = apiTransaction.category
            note = apiTransaction.note
        }
        
        func toDBModel() -> DBModel.Transaction {
            let dbModel = DBModel.Transaction()
            dbModel.id = id ?? UUID().uuidString
            dbModel.title = title ?? ""
            dbModel.amount = amount ?? 0.0
            dbModel.date = date ?? .init()
            dbModel.source = source?.rawValue ?? ""
            dbModel.category = category?.rawValue ?? ""
            dbModel.note = note ?? ""
            
            return dbModel
        }
    }
}
