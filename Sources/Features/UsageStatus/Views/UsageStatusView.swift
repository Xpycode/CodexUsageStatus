import SwiftUI

struct UsageStatusView: View {
    @ObservedObject var store: UsageStore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Codex usage")
                    .font(.title2.weight(.semibold))
                Text("⌃⌥⌘X to toggle · click elsewhere to dismiss")
                    .foregroundStyle(.secondary)
            }

            if let snapshot = store.snapshot {
                if snapshot.periodTitle == "Weekly limit" { UnavailableLimit(title: "5-hour limit") }
                UsageMeter(snapshot: snapshot)
                if snapshot.periodTitle == "5-hour limit" { UnavailableLimit(title: "Weekly limit") }
            }
            else if let error = store.error { Text(error).foregroundStyle(.secondary) }
            else { ProgressView("Loading Codex usage…") }

            Spacer()
        }
        .padding(32)
        .frame(width: 340, alignment: .topLeading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct UsageMeter: View {
    let snapshot: UsageSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(snapshot.periodTitle)
                    .font(.headline)
                Spacer()
                Text("\(snapshot.remainingPercentage, format: .number.precision(.fractionLength(0)))% remaining")
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: snapshot.usedPercentage, total: 100)
                .progressViewStyle(.linear)

            Text("Resets in \(countdown)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
    }

    private var countdown: String {
        let minutes = max(0, Int(snapshot.resetsAt.timeIntervalSinceNow / 60))
        let days = minutes / 1_440
        let hours = (minutes % 1_440) / 60
        let remainingMinutes = minutes % 60
        if days > 0 { return "\(days)d \(hours)h \(remainingMinutes)m" }
        if hours > 0 { return "\(hours)h \(remainingMinutes)m" }
        return remainingMinutes > 0 ? "\(remainingMinutes)m" : "less than a minute"
    }
}

private struct UnavailableLimit: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(title).font(.subheadline.weight(.medium))
                Spacer()
                Text("Unavailable").font(.subheadline).foregroundStyle(.secondary)
            }
            ProgressView(value: 0, total: 100)
                .tint(.gray.opacity(0.35))
            Text("Codex did not return this rate-limit window.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .opacity(0.72)
    }
}

#Preview {
    UsageStatusView(store: UsageStore())
}
