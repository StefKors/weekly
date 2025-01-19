//
//  WeeklyEntry.swift
//  weekly
//
//  Created by Stef Kors on 16/01/2025.
//

import Foundation
import SwiftData
import SwiftUI

extension EnvironmentValues {
    @Entry var entry: WeeklyEntry = .preview
}

@Model
final class WeeklyEntry {
    var timestamp: Date
    var tasks: [WeeklyTask] = []

    init(timestamp: Date = Date(), tasks: [WeeklyTask] = []) {
        self.timestamp = timestamp
        self.tasks = tasks
    }

    func copyToPasteboard() {
        let entryAsString = tasks.map { $0.description }.joined(separator: "\n")
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(entryAsString, forType: .string)
    }
}

extension WeeklyEntry {
    static let preview = WeeklyEntry(
        timestamp: Date.now,
        tasks: [.preview]
    )
}
