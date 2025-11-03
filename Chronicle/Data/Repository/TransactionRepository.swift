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
            let realm = try realmProvider()
            let results = realm.objects(DBModel.Transaction.self).sorted(byKeyPath: keyPath, ascending: ascending)
            return ResultsPublisher(results: results).eraseToAnyPublisher()
        } catch {
            return Just([]).eraseToAnyPublisher()
        }
    }

    func byId(_ id: String) -> DBModel.Transaction? {
        (try? realmProvider())?.object(ofType: DBModel.Transaction.self, forPrimaryKey: id)
    }

    func add(_ tx: DBModel.Transaction) throws {
        let realm = try realmProvider()
        try realm.write { realm.add(tx, update: .error) }
    }

    func update(id: String, mutate: (DBModel.Transaction) -> Void) throws {
        let realm = try realmProvider()
        guard let obj = realm.object(ofType: DBModel.Transaction.self, forPrimaryKey: id) else { return }
        try realm.write { mutate(obj) }
    }

    func delete(id: String) throws {
        let realm = try realmProvider()
        if let obj = realm.object(ofType: DBModel.Transaction.self, forPrimaryKey: id) {
            try realm.write { realm.delete(obj) }
        }
    }
}
