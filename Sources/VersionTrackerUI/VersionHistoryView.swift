//
//  VersionHistoryView.swift
//  VersionTrackerUI
//
//  Created by Siuzanna Karagulova on 1/7/26.
//  Copyright © 2026 Navamsha (Philipp Kozub). All rights reserved.
//

#if canImport(UIKit)
import SwiftUI
import UIKit
import VersionTracker

private enum VersionHistoryStatus {
    case firstLaunch
    case updated
    case downgraded
}

public struct VersionHistoryView: View {

    private let storage: VersionStorage

    @State private var versionHistory: [VersionRecord] = []
    @State private var selectedVersion: VersionRecord?
    @State private var isShowingDetailsAlert: Bool = false

    public init(storage: VersionStorage = UserDefaultsVersionStorage()) {
        self.storage = storage
    }

    public var body: some View {
        List {
            Section(header: Text("Version history (\(versionHistory.count))")) {
                if versionHistory.isEmpty == true {
                    Text("empty")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(versionHistory.indices, id: \.self) { index in
                        let versionRecord = versionHistory[index]
                        Button {
                            selectedVersion = versionRecord
                            isShowingDetailsAlert = true
                        } label: {
                            HStack {
                                Spacer()
                                VStack(alignment: .center, spacing: 4) {
                                    Text("#\(versionHistory.count - index)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    versionTextView(for: versionRecord)
                                        .font(.body)

                                    Text(statusText(for: index))
                                        .font(.caption)
                                        .foregroundColor(statusColor(for: index))
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .listRowSeparatorLeadingAlignment()
                        }
                    }
                }
            }
        }
        .onAppear {
            loadVersionHistory()
        }
        .alert("Version", isPresented: $isShowingDetailsAlert, presenting: selectedVersion) { versionRecord in
            Button("Copy") {
                UIPasteboard.general.string = versionText(for: versionRecord)
            }
            Button("OK", role: .cancel) { }
        } message: { versionRecord in
            Text(versionText(for: versionRecord))
                .multilineTextAlignment(.leading)
        }
    }

    private func loadVersionHistory() {
        self.versionHistory = self.storage.versionHistory.reversed()
    }

    private func versionText(for versionRecord: VersionRecord) -> String {
        return "Version: \(versionRecord.version)(\(versionRecord.buildNumber))"
    }

    private func versionTextView(for versionRecord: VersionRecord) -> Text {
        return Text("Version: ")
            .foregroundColor(.secondary)
        + Text(String(describing: versionRecord.version) + "(\(versionRecord.buildNumber))")
    }

    private func statusText(for index: Int) -> String {
        switch status(for: index) {
        case .firstLaunch:
            return "First launch"
        case .updated:
            return "Updated"
        case .downgraded:
            return "Downgraded"
        }
    }

    private func statusColor(for index: Int) -> Color {
        switch status(for: index) {
        case .firstLaunch:
            return .secondary
        case .updated:
            return .green
        case .downgraded:
            return .red
        }
    }

    private func status(for index: Int) -> VersionHistoryStatus {
        guard index < self.versionHistory.count - 1 else {
            return .firstLaunch
        }

        let current = self.versionHistory[index]
        let previous = self.versionHistory[index + 1]

        if current.version > previous.version {
            return .updated
        } else if current.version < previous.version {
            return .downgraded
        }

        let currentBuildNumber = Int(current.buildNumber) ?? 0
        let previousBuildNumber = Int(previous.buildNumber) ?? 0
        if currentBuildNumber >= previousBuildNumber {
            return .updated
        } else {
            return .downgraded
        }
    }
}

private extension View {
    @ViewBuilder
    func listRowSeparatorLeadingAlignment() -> some View {
        if #available(iOS 16.0, *) {
            self.alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        } else {
            self
        }
    }
}
#endif
