//
//  VersionTracker.swift
//  VersionTracker
//
//  Created by Siuzanna Karagulova   on 1/7/26.
//  Copyright © 2026 Navamsha (Philipp Kozub). All rights reserved.
//

import Foundation

public enum VersionTrackingState: Equatable {
    case firstInstall(current: VersionRecord)
    case sameVersion(current: VersionRecord)
    case updated(from: VersionRecord, to: VersionRecord)
}

public struct VersionTracker {

    private let provider: VersionProvider
    private let storage: VersionStorage

    public init(provider: VersionProvider = BundleVersionProvider(), storage: VersionStorage = UserDefaultsVersionStorage()) {
        self.provider = provider
        self.storage = storage
    }

    public func currentState() -> VersionTrackingState {
        let current = VersionRecord(version: provider.currentVersion, buildNumber: provider.currentBuildNumber)
        guard let last = storage.lastLaunchedRecord else {
            return .firstInstall(current: current)
        }
        if last == current {
            return .sameVersion(current: current)
        } else {
            return .updated(from: last, to: current)
        }
    }
}
