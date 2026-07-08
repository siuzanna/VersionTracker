//
//  VersionStorage.swift
//  VersionTracker
//
//  Created by Siuzanna Karagulova   on 1/7/26.
//  Copyright © 2026 Navamsha (Philipp Kozub). All rights reserved.
//

import Foundation

public protocol VersionStorage: AnyObject {
    var lastLaunchedRecord: VersionRecord? { get }
    var versionHistory: [VersionRecord] { get }

    func recordLaunch(_ record: VersionRecord)
}

public final class UserDefaultsVersionStorage: VersionStorage {

    private enum Keys {
        static let legacyLastLaunchedVersion = "settings.versionTracking.lastLaunchedVersion"
        static let versionHistory = "settings.versionTracking.versionHistory"
    }

    private let userDefaults: UserDefaults
    private let lock = NSLock()

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public var lastLaunchedRecord: VersionRecord? {
        self.locked {
            guard let rawValue = self.userDefaults.string(forKey: Keys.legacyLastLaunchedVersion) else {
                return nil
            }
            if let record = VersionRecord(rawValue: rawValue) {
                return record
            }
            return Version(rawValue).map { VersionRecord(version: $0, buildNumber: "") }
        }
    }

    public var versionHistory: [VersionRecord] {
        self.locked {
            let rawValues = self.userDefaults.array(forKey: Keys.versionHistory) as? [String] ?? []
            return rawValues.compactMap(VersionRecord.init(rawValue:))
        }
    }

    public func recordLaunch(_ record: VersionRecord) {
        self.locked {
            self.appendVersionHistoryLocked(record)
            self.userDefaults.set(record.rawValue, forKey: Keys.legacyLastLaunchedVersion)
        }
    }

    private func appendVersionHistoryLocked(_ record: VersionRecord) {
        var rawValues = self.userDefaults.array(forKey: Keys.versionHistory) as? [String] ?? []
        if let lastRawValue = rawValues.last, VersionRecord(rawValue: lastRawValue) == record {
            return
        }
        rawValues.append(record.rawValue)
        self.userDefaults.set(rawValues, forKey: Keys.versionHistory)
    }

    private func locked<T>(_ block: () -> T) -> T {
        self.lock.lock()
        defer { self.lock.unlock() }
        return block()
    }
}
