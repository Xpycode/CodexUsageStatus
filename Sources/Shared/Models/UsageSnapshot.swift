import Foundation

struct UsageSnapshot: Equatable, Sendable {
    let periodTitle: String
    let usedPercentage: Double
    let resetsAt: Date

    var remainingPercentage: Double {
        max(0, min(100, 100 - usedPercentage))
    }
}
