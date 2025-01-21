//
//  WeeklyEntry.swift
//  weekly
//
//  Created by Stef Kors on 16/01/2025.
//

import Foundation
import SwiftData
import SwiftUI

enum EntryType: String, Hashable, Identifiable, Codable, CaseIterable {
    case daily
    case weekly

    var id: String {
        self.rawValue
    }
}

@Model
final class WeeklyEntry {
    var timestamp: Date
    var tasks: [WeeklyTask] = []
    var type: EntryType? = EntryType.daily

    init(timestamp: Date = Date(), type: EntryType, tasks: [WeeklyTask] = []) {
        self.timestamp = timestamp
        self.tasks = tasks
        self.type = type

        if tasks.count > 1 {
            self.refreshTaskIndexes()
        }
    }

    func copyToPasteboard() {
        let entryAsString = tasks.map { $0.description }.joined(separator: "\n")
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(entryAsString, forType: .string)
    }

    func refreshTaskIndexes() {
        for (index, task) in tasks.enumerated() {
            task.index = index
        }
    }
}

extension WeeklyEntry {
    static let preview = WeeklyEntry(
        timestamp: Date.now,
        type: .daily,
        tasks: [.preview]
    )

    static let previewWeekly = WeeklyEntry(
        timestamp: Date.now,
        type: .weekly,
        tasks: [.preview]
    )
}
