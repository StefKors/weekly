//
//  WeeklyTask.swift
//  weekly
//
//  Created by Stef Kors on 16/01/2025.
//

import Foundation
import SwiftData

@Model
final class WeeklyTask: Identifiable, CustomStringConvertible {
    var id: UUID = UUID()

    var icon: String
    var label: String
    var indent: CGFloat = 0
    var index: Int = 0

    init(icon: String, label: String, indent: CGFloat = 0, index: Int) {
        self.icon = icon
        self.label = label
        self.indent = indent
        self.index = index
    }

    init(_ task: WeeklyTask) {
        self.icon = task.icon
        self.label = task.label
        self.indent = task.indent
        self.index = task.index
    }

    var description: String {
        return "\(String(repeating: " ", count: Int(self.indent))):\(icon): \(label)"
    }
}

extension WeeklyTask {
    static let preview = WeeklyTask(
        icon: "aligned",
        label: "Prototype weekly editor on macOS",
        index: 0
    )
}
