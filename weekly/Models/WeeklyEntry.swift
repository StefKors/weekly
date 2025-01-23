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
        var pasteboardString = ""
        if type == .daily {
            pasteboardString += "*EOD Update*\n"
            pasteboardString += tasks.map { $0.description }.joined(separator: "\n")
        }
        if type == .weekly {
            pasteboardString += tasks.map { $0.description }.joined(separator: "\n")
        }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(pasteboardString, forType: .string)
    }

    func refreshTaskIndexes() {
        print("refresh task indexes")
        for (index, task) in tasks.enumerated() {
            task.index = index
        }
    }

    var isDaily: Bool {
        type == .daily
    }

    var isWeekly: Bool {
        type == .weekly
    }

    // Returns true if:
    // 1. There are no tasks at all, OR
    // 2. All tasks have an empty description (e.g. "")
    func hasNoTasks() -> Bool {
        tasks.isEmpty ||
        tasks.allSatisfy { $0.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    func hasTasks() -> Bool {
        !hasNoTasks()
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
