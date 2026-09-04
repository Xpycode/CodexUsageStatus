import Foundation
struct CodexUsageService {
    func fetch() async throws -> UsageSnapshot {
        let url = FileManager.default.homeDirectoryForCurrentUser.appending(path: ".codex/auth.json")
        let json = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any]
        guard let tokens = json?["tokens"] as? [String: Any], let token = tokens["access_token"] as? String, let account = tokens["account_id"] as? String else { throw NSError(domain: "Codex", code: 1, userInfo: [NSLocalizedDescriptionKey: "No Codex sign-in found at ~/.codex/auth.json."]) }
        var request = URLRequest(url: URL(string: "https://chatgpt.com/backend-api/wham/usage")!); request.timeoutInterval = 15; request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization"); request.setValue(account, forHTTPHeaderField: "ChatGPT-Account-ID")
        let (data, response) = try await URLSession.shared.data(for: request); guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode), let root = try JSONSerialization.jsonObject(with: data) as? [String: Any], let rate = root["rate_limit"] as? [String: Any] else { throw NSError(domain: "Codex", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to read Codex usage."]) }
        let windows = [rate["primary_window"], rate["secondary_window"]].compactMap { $0 as? [String: Any] }
        func window(_ short: Bool, _ title: String) -> UsageSnapshot? { windows.first { (($0["limit_window_seconds"] as? Double) ?? 0 < 86_400) == short }.flatMap { d in guard let used = d["used_percent"] as? Double else { return nil }; return UsageSnapshot(periodTitle: title, usedPercentage: used, resetsAt: Date(timeIntervalSince1970: (d["reset_at"] as? Double) ?? 0)) } }
        guard let result = window(true, "5-hour limit") ?? window(false, "Weekly limit") else { throw NSError(domain: "Codex", code: 3, userInfo: [NSLocalizedDescriptionKey: "Codex returned no recognised rate-limit windows."]) }; return result
    }
}
