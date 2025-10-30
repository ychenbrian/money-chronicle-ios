import Foundation
import RealmSwift

enum RealmBootstrap {
    static func configure() {
        var config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { _, _ in }
        )
        Realm.Configuration.defaultConfiguration = config

        _ = try? Realm()
    }
}
