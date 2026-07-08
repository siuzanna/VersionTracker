//
//  VersionRecord.swift
//  VersionTracker
//
//  Created by Siuzanna Karagulova   on 1/7/26.
//  Copyright © 2026 Navamsha (Philipp Kozub). All rights reserved.
//

import Foundation

public struct VersionRecord: Equatable, CustomStringConvertible {

    private static let separator: Character = "|"

    public let version: Version
    public let buildNumber: String

    public var description: String { "\(self.version) (build \(self.buildNumber))" }

    public var rawValue: String { "\(self.version.rawValue)\(Self.separator)\(self.buildNumber)" }

    public init(version: Version, buildNumber: String) {
        self.version = version
        self.buildNumber = buildNumber
    }

    public init?(rawValue: String) {
        let parts = rawValue
            .split(separator: Self.separator, maxSplits: 1, omittingEmptySubsequences: false)
            .map(String.init)

        guard parts.count == 2, let version = Version(parts[0]) else {
            return nil
        }
        self.version = version
        self.buildNumber = parts[1]
    }
}
