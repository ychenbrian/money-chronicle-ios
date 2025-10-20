import Foundation
import RealmSwift

protocol RealmServiceProtocol {
    func add<T: Object>(_ object: T) throws
    func fetchAll<T: Object>(_ type: T.Type, filter: NSPredicate?, sortedKeyPath: String?, ascending: Bool) -> [T]
    func delete<T: Object>(_ object: T) throws
    func deleteAll<T: Object>(_ type: T.Type) throws
    func write(_ block: () throws -> Void) throws
}

final class RealmService: RealmServiceProtocol {
    private let realm: Realm

    init(realm: Realm? = nil) {
        if let realm = realm {
            self.realm = realm
        } else {
            do {
                self.realm = try Realm()
            } catch {
                fatalError("Failed to initialize Realm: \(error.localizedDescription)")
            }
        }
    }

    func add<T: Object>(_ object: T) throws {
        try realm.write {
            realm.add(object, update: .modified)
        }
    }

    func fetchAll<T: Object>(_ type: T.Type, filter: NSPredicate? = nil, sortedKeyPath: String? = nil, ascending: Bool = true) -> [T] {
        var results = realm.objects(type)
        if let filter = filter {
            results = results.filter(filter)
        }
        if let key = sortedKeyPath {
            results = results.sorted(byKeyPath: key, ascending: ascending)
        }
        return Array(results)
    }

    func delete<T: Object>(_ object: T) throws {
        try realm.write {
            realm.delete(object)
        }
    }

    func deleteAll<T: Object>(_ type: T.Type) throws {
        let objects = realm.objects(type)
        try realm.write {
            realm.delete(objects)
        }
    }

    func write(_ block: () throws -> Void) throws {
        try realm.write {
            try block()
        }
    }
}
