import Foundation

struct AppError: Error, Identifiable, Hashable, Sendable {
    let id: UUID
    let message: String
    let underlying: Error?
    let file: String
    let line: Int
    let function: String

    init(_ error: any Error) {
        self.init(message: error.localizedDescription, underlying: error)
    }

    init(
        message: String? = nil,
        underlying: Error? = nil,
        file: String = #fileID,
        line: Int = #line,
        function: String = #function
    ) {
        self.id = UUID()
        self.message = message ?? ""
        self.underlying = underlying
        self.file = file
        self.line = line
        self.function = function
    }
}

extension AppError: LocalizedError {
    var errorDescription: String? { message }
    var failureReason: String? { underlying?.localizedDescription }
}

extension AppError: CustomDebugStringConvertible {
    var debugDescription: String {
        var out = "\(message) @ \(file):\(line) \(function)"
        if let underlying { out += "\n  ↳ \(underlying)" }
        return out
    }
}

extension AppError {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AppError, rhs: AppError) -> Bool {
        lhs.id == rhs.id
    }
}
