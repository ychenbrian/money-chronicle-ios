import Foundation
import SourceryRuntime

let autoMockableProtocolName = "Codable"

private let models: [Struct] = types.structs.filter {
    $0.inheritedTypes.contains(autoMockableProtocolName)
}

private let modelClasses: [Class] = types.classes.filter {
    $0.inheritedTypes.contains(autoMockableProtocolName)
}

private func generateMock(autoMock: Bool) -> String {
    let stringMocks = models.map {
        var varNames = [String]()

        let paramsLines = $0.storedVariables.map {
            varNames.append($0.name)

            var typeName = $0.typeName.name
            if let type = $0.type,
               type.isKind(of: Enum.self) {
                typeName = $0.typeName.actualTypeName?.name ?? typeName
            }
            let mockedVar = autoMock ? autoMockParam(variable: $0) : mockParam(variable: $0)
            return "\($0.name): \(typeName) = \(mockedVar)"
        }

        let funcName = autoMock ? "autoMock" : "mock"

        return """
        // MARK: - Generated \($0.name)
        
        extension \($0.name) {
        
            static func \(funcName)(
                \(paramsLines.joined(separator: ",\n        "))
            ) -> \($0.name) {
                .init(
                    \(varNames.map { "\($0): \($0)" }.joined(separator: ",\n            "))
                )
            }
        }
        """
    }

    return stringMocks.joined(separator: "\n\n")
}

private func generateClassesMock(autoMock: Bool) -> String {
    let stringMocks = modelClasses.map {
        var varNames = [String]()

        let paramsLines = $0.storedVariables.map {
            varNames.append($0.name)

            var typeName = $0.typeName.name
            if let type = $0.type,
               type.isKind(of: Enum.self) {
                typeName = $0.typeName.actualTypeName?.name ?? typeName
            }
            let mockedVar = autoMock ? autoMockParam(variable: $0) : mockParam(variable: $0)
            return "\($0.name): \(typeName) = \(mockedVar)"
        }
        let funcName = autoMock ? "autoMock" : "mock"

        return """
        // MARK: - Generated \($0.name)
        
        extension \($0.name) {
        
            static func \(funcName)(
                \(paramsLines.joined(separator: ",\n        "))
            ) -> \($0.name) {
                .init(
                    \(varNames.map { "\($0): \($0)" }.joined(separator: ",\n            "))
                )
            }
        }
        """
    }
    return stringMocks.joined(separator: "\n\n")
}

// MARK: - Output

func generateModelsMockOutput() -> String {
    """
    import Foundation
    
    @testable import \(projectName)
    import Fakery
    
    let faker = Faker(locale: "nb-NO")
    \(generateMock(autoMock: false))
    \(generateMock(autoMock: true))
    \(generateClassesMock(autoMock: false))
    \(generateClassesMock(autoMock: true))
    """
}
