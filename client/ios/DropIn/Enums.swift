import Foundation

enum EventVisibility: String, CaseIterable, Codable {
    case `public`
    case friends
    case invite
}

enum EventStatus: String, CaseIterable, Codable {
    case upcoming = "Upcoming"
    case live = "Live"
    case closing = "Closing"
}

enum AttendanceStatus: String, CaseIterable {
    case joined
    case undetermined
}

// MARK: - Async Task States

enum AsyncStatus {
    case idle
    case running
    case success
    case failure(Error)
}

extension AsyncStatus {
    var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }
    
    var isRunning: Bool {
        if case .running = self { return true }
        return false
    }

    var isFailure: Bool {
        if case .failure = self { return true }
        return false
    }
    
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    var error: String {
        if case let .failure(error) = self {
            return error.localizedDescription.capitalized
        }
        return "Something went wrong. Try again later."
    }
}

