import Testing
@testable import VersionTracker

@Suite("Version parsing & comparison")
struct VersionTests {

    @Test func parsesDottedString() {
        let version = Version("1.2.3")
        #expect(version?.components == [1, 2, 3])
        #expect(version?.rawValue == "1.2.3")
    }

    @Test func rejectsNonNumericParts() {
        #expect(Version("1.a.3") == nil)
    }

    @Test func equalityIgnoresTrailingZeros() {
        #expect(Version("1.2") == Version("1.2.0"))
    }

    @Test func ordersByComponents() {
        #expect(Version("1.2.0")! < Version("1.10.0")!)
        #expect(Version("2.0.0")! > Version("1.99.0")!)
    }
}

@Suite("VersionRecord raw value round-trip")
struct VersionRecordTests {

    @Test func roundTripsThroughRawValue() {
        let original = VersionRecord(version: Version("1.4.2")!, buildNumber: "789")
        let decoded = VersionRecord(rawValue: original.rawValue)
        #expect(decoded == original)
    }

    @Test func rejectsInvalidRawValue() {
        #expect(VersionRecord(rawValue: "not-a-version") == nil)
    }
}

@Suite("VersionTracker state machine")
struct VersionTrackerStateTests {

    private final class StubStorage: VersionStorage {
        var lastLaunchedRecord: VersionRecord?
        var versionHistory: [VersionRecord] = []
        func recordLaunch(_ record: VersionRecord) {
            self.versionHistory.append(record)
            self.lastLaunchedRecord = record
        }
    }

    private struct StubProvider: VersionProvider {
        let currentVersion: Version
        let currentBuildNumber: String
    }

    @Test func reportsFirstInstallWhenStorageEmpty() {
        let tracker = VersionTracker(
            provider: StubProvider(currentVersion: Version("1.0.0")!, currentBuildNumber: "1"),
            storage: StubStorage()
        )
        let state = tracker.currentState()
        if case .firstInstall = state {
            // ok
        } else {
            Issue.record("Expected .firstInstall, got \(state)")
        }
    }

    @Test func reportsSameVersionWhenRecordMatches() {
        let storage = StubStorage()
        storage.lastLaunchedRecord = VersionRecord(version: Version("1.0.0")!, buildNumber: "1")
        let tracker = VersionTracker(
            provider: StubProvider(currentVersion: Version("1.0.0")!, currentBuildNumber: "1"),
            storage: storage
        )
        if case .sameVersion = tracker.currentState() {
            // ok
        } else {
            Issue.record("Expected .sameVersion")
        }
    }

    @Test func reportsUpdatedWhenBuildDiffers() {
        let storage = StubStorage()
        storage.lastLaunchedRecord = VersionRecord(version: Version("1.0.0")!, buildNumber: "1")
        let tracker = VersionTracker(
            provider: StubProvider(currentVersion: Version("1.1.0")!, currentBuildNumber: "2"),
            storage: storage
        )
        if case .updated = tracker.currentState() {
            // ok
        } else {
            Issue.record("Expected .updated")
        }
    }
}
