import Foundation
import SourceryRuntime

let customMockAnnotation = "customMock"

struct MockParameter {
    static let emptyArrayValue = "[]"
    static let nilValue = "nil"
    static let initValue = ".init()"
    static let mockValue = ".mock()"
    static let emptyStringValue = "\"\""
    static let intValue = "0"
    static let boolValue = "false"
}

var mockParameterDefaultValueDict: [String: String] {
    [
        "String": MockParameter.emptyStringValue,
        "Int": MockParameter.intValue,
        "Bool": MockParameter.boolValue,
        "Double": "0.0"
    ]
}

func mockParam(variable: Variable) -> String {
    if let customMock = variable.annotations[customMockAnnotation] { return "\(customMock)" }
    guard !variable.isOptional else { return MockParameter.nilValue }
    return mockParameterDefaultValueByType(variable.typeName)
}

func autoMockParam(variable: Variable) -> String {
    let name = variable.name.lowercased()
    let isOptional = variable.isOptional
    let base = variable.typeName.unwrappedTypeName
    let clean = variable.typeName.name
        .replacingOccurrences(of: "?", with: "")
        .replacingOccurrences(of: "!", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)

    // Name-based shortcuts (only for Strings)
    if base == "String" {
        if name.contains("email") { return "faker.internet.email()" }
        if name.contains("phone") { return "faker.phoneNumber.phoneNumber()" }
        if name.contains("firstname") { return "faker.name.firstName()" }
        if name.contains("lastname") { return "faker.name.lastName()" }
        if name.contains("name") { return "faker.name.name()" }
        if name.contains("url") || name.contains("link") { return "faker.internet.url()" }
        if name.contains("thumbnail") { return "faker.internet.image()" }
        if name.contains("title") { return "faker.lorem.word()" }
        if name.contains("notes") || name.contains("description") || name.contains("text") { return "faker.lorem.sentence()" }
        if name.contains("code") { return "faker.address.countryCode()" }
        if name.contains("id") { return "UUID().uuidString" }
    }

    switch base {
    case "Bool":
        return "faker.number.randomBool()"
    case "Int":
        return "faker.number.randomInt(min: 1, max: 100)"
    case "Double":
        return "faker.number.randomDouble(min: 0.0, max: 100.0)"
    case "String":
        return "faker.lorem.word()"
    case "Date":
        return "faker.date.backward(days: faker.number.randomInt(min: 0, max: 20))"
    case "UUID":
        return "UUID()"
    case "TransactionCategory":
        return isOptional ? "TransactionCategory.allCases.randomElement()" : "TransactionCategory.allCases.randomElement()!"
    case "TransactionSource":
        return isOptional ? "TransactionSource.allCases.randomElement()" : "TransactionSource.allCases.randomElement()!"
    default:
        if variable.typeName.isArray {
            let elBase = variable.typeName.array?.elementTypeName.unwrappedTypeName ?? ""
            let elClean = variable.typeName.array?.elementTypeName.name
                .replacingOccurrences(of: "?", with: "")
                .replacingOccurrences(of: "!", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            switch elBase {
            case "String": return "[faker.lorem.word()]"
            case "Int": return "[faker.number.randomInt(min: 1, max: 100)]"
            case "Bool": return "[faker.number.randomBool()]"
            case "Double": return "[faker.number.randomDouble(min: 0.0, max: 100.0)]"
            case "UUID": return "[UUID()]"
            default:
                return elClean.isEmpty ? "[]" : "[\(elClean).autoMock()]"
            }
        } else {
            return "\(clean).autoMock()"
        }
    }
}

func mockParameterDefaultValueByType(_ typeName: TypeName) -> String {
    let raw = typeName.unwrappedTypeName
    let clean = typeName.name
        .replacingOccurrences(of: "?", with: "")
        .replacingOccurrences(of: "!", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)

    if typeName.isArray {
        let el = typeName.array?.elementTypeName.name
            .replacingOccurrences(of: "?", with: "")
            .replacingOccurrences(of: "!", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if let basic = mockParameterDefaultValueDict[el] { return "[\(basic)]" }
        return "[\(el).mock()]"
    }

    if let basic = mockParameterDefaultValueDict[raw] { return basic }
    return "\(clean).mock()"
}
