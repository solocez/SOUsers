import Foundation

enum ViewModelState: Equatable, Sendable {
    case idle
    case inProgress
    case error(AppError)
    case ready

    var inProgress: Bool {
        if case .inProgress = self {
            return true
        }
        return false
    }

    var error: AppError? {
        if case let .error(error) = self {
            return error
        }
        return nil
    }
}
