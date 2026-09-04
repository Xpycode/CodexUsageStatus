import XCTest
@testable import CodexUsageStatus

final class UsageSnapshotTests: XCTestCase {
    func testRemainingPercentageIsComplementOfUsage() {
        let snapshot = UsageSnapshot(periodTitle: "Test", usedPercentage: 35, resetsAt: .now)

        XCTAssertEqual(snapshot.remainingPercentage, 65)
    }

    func testRemainingPercentageIsClamped() {
        let overLimit = UsageSnapshot(periodTitle: "Test", usedPercentage: 125, resetsAt: .now)
        let negativeUsage = UsageSnapshot(periodTitle: "Test", usedPercentage: -5, resetsAt: .now)

        XCTAssertEqual(overLimit.remainingPercentage, 0)
        XCTAssertEqual(negativeUsage.remainingPercentage, 100)
    }
}
