//
//  Version.swift
//  VersionTracker
//
//  Created by Siuzanna Karagulova   on 1/7/26.
//  Copyright © 2026 Navamsha (Philipp Kozub). All rights reserved.
//

import Foundation

public struct Version: Equatable, Comparable, CustomStringConvertible {

    public static let zero = Version(components: [0], rawValue: "0")

    public let components: [Int]
    public let rawValue: String

    public var description: String {
        self.rawValue
    }

    public init?(_ string: String) {
        let parts = string.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.isEmpty == false else {
            return nil
        }
        var parsed: [Int] = []
        parsed.reserveCapacity(parts.count)
        for part in parts {
            guard let value = Int(part), value >= 0 else {
                return nil
            }
            parsed.append(value)
        }
        self.components = parsed
        self.rawValue = string
    }

    private init(components: [Int], rawValue: String) {
        self.components = components
        self.rawValue = rawValue
    }

    public static func == (lhs: Version, rhs: Version) -> Bool {
        let count = max(lhs.components.count, rhs.components.count)
        for index in 0 ..< count {
            let left = index < lhs.components.count ? lhs.components[index] : 0
            let right = index < rhs.components.count ? rhs.components[index] : 0
            if left != right {
                return false
            }
        }
        return true
    }

    public static func < (lhs: Version, rhs: Version) -> Bool {
        let count = max(lhs.components.count, rhs.components.count)
        for index in 0 ..< count {
            let left = index < lhs.components.count ? lhs.components[index] : 0
            let right = index < rhs.components.count ? rhs.components[index] : 0
            if left != right {
                return left < right
            }
        }
        return false
    }
}
