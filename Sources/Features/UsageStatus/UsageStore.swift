import Foundation
@MainActor final class UsageStore: ObservableObject {
    @Published private(set) var snapshot: UsageSnapshot?; @Published private(set) var error: String?; @Published private(set) var loading = false
    func refresh() { guard !loading else { return }; loading = true; Task { defer { loading = false }; do { snapshot = try await CodexUsageService().fetch(); error = nil } catch { self.error = error.localizedDescription } } }
}
