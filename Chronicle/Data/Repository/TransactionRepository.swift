import Combine
import Foundation
import RealmSwift

protocol TransactionRepositoryType {
    func all(sortBy keyPath: String, ascending: Bool) -> AnyPublisher<[DBModel.Transaction], Never>
    func byId(_ id: String) -> DBModel.Transaction?
    func add(_ tx: DBModel.Transaction) throws
    func update(id: String, mutate: (DBModel.Transaction) -> Void) throws
    func delete(id: String) throws
}

final class TransactionRepository: TransactionRepositoryType {
    private let realmProvider: () throws -> Realm
    init(realmProvider: @escaping () throws -> Realm = { try Realm() }) { self.realmProvider = realmProvider }

    func all(sortBy keyPath: String = "date", ascending: Bool = false) -> AnyPublisher<[DBModel.Transaction], Never> {
        do {
            let r = try realmProvider()
            let results = r.objects(DBModel.Transaction.self).sorted(byKeyPath: keyPath, ascending: ascending)
            return ResultsPublisher(results: results).eraseToAnyPublisher()
        } catch {
            return Just([]).eraseToAnyPublisher()
        }
    }

    func byId(_ id: String) -> DBModel.Transaction? {
        (try? realmProvider())?.object(ofType: DBModel.Transaction.self, forPrimaryKey: id)
    }

    func add(_ tx: DBModel.Transaction) throws {
        let r = try realmProvider()
        try r.write { r.add(tx, update: .error) }
    }

    func update(id: String, mutate: (DBModel.Transaction) -> Void) throws {
        let r = try realmProvider()
        guard let obj = r.object(ofType: DBModel.Transaction.self, forPrimaryKey: id) else { return }
        try r.write { mutate(obj) }
    }

    func delete(id: String) throws {
        let r = try realmProvider()
        if let obj = r.object(ofType: DBModel.Transaction.self, forPrimaryKey: id) {
            try r.write { r.delete(obj) }
        }
    }
}
