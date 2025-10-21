// Generated using Sourcery 2.2.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation

@testable import Chronicle_Staging
import Fakery

let faker = Faker(locale: "nb-NO")
// MARK: - Generated APIModel.Transaction

extension APIModel.Transaction {

    static func mock(
        id: String? = nil,
        title: String? = nil,
        amount: Double? = nil,
        date: Date? = nil,
        source: TransactionSource? = nil,
        category: TransactionCategory? = nil,
        note: String? = nil
    ) -> APIModel.Transaction {
        .init(
            id: id,
            title: title,
            amount: amount,
            date: date,
            source: source,
            category: category,
            note: note
        )
    }
}
// MARK: - Generated APIModel.Transaction

extension APIModel.Transaction {

    static func autoMock(
        id: String? = UUID().uuidString,
        title: String? = faker.lorem.word(),
        amount: Double? = faker.number.randomDouble(min: 0.0, max: 100.0),
        date: Date? = faker.date.backward(days: faker.number.randomInt(min: 0, max: 20)),
        source: TransactionSource? = TransactionSource.allCases.randomElement(),
        category: TransactionCategory? = TransactionCategory.allCases.randomElement(),
        note: String? = faker.lorem.word()
    ) -> APIModel.Transaction {
        .init(
            id: id,
            title: title,
            amount: amount,
            date: date,
            source: source,
            category: category,
            note: note
        )
    }
}
