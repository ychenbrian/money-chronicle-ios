import Foundation
import RxCocoa
import RxSwift

public struct ErrorHelper {
    public static func make(_ message: String) -> Error {
        AppError.message(message)
    }

    public static func emit(_ error: Error, to relay: PublishRelay<Error>?) {
        relay?.accept(error)
    }

    public static func map(_ error: Error) -> Error {
        return error
    }
}
