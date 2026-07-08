//
//  VersionProvider.swift
//  VersionTracker
//
//  Created by Siuzanna Karagulova   on 1/7/26.
//  Copyright © 2026 Navamsha (Philipp Kozub). All rights reserved.
//

import Foundation

public protocol VersionProvider {
    var currentVersion: Version { get }
    var currentBuildNumber: String { get }
}

public struct BundleVersionProvider: VersionProvider {

    private let bundle: Bundle

    public init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    public var currentVersion: Version {
        let rawValue = self.bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        guard let parsed = Version(rawValue) else {
            assertionFailure("Invalid CFBundleShortVersionString: \(rawValue)")
            return .zero
        }
        return parsed
    }

    public var currentBuildNumber: String {
        self.bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown"
    }
}
