//
//  NestedTasksView.swift
//  weekly
//
//  Created by Stef Kors on 17/01/2025.
//

import SwiftUI
import SwiftData

struct NestedTasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var entry: WeeklyEntry

    @State private var active: WeeklyTask?

    @Environment(\.focus) private var focus

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ReorderableForEach(entry.tasks.sorted(using: KeyPathComparator(\.index)), active: $active) { item in
                WeeklyTaskView(task: item)
                    .padding(.leading, item.indent * 12)
                    .onKeyPress(action: { keyPress in
                        switch keyPress.key {
                        case .downArrow:
                            if let nextItem = entry.tasks.element(after: item) {
                                focus.focusedView = .task(nextItem.id)
                            }
                            return .handled
                        case .upArrow:
                            print("uparrow")
                            if let previousItem = entry.tasks.element(before: item) {
                                print("uparrow \(previousItem)")
                                focus.focusedView = .task(previousItem.id)
                            }
                            return .handled
                        default:
                            return .ignored
                        }
                    })
            } preview: { item in
                WeeklyTaskView(task: item)
                    .opacity(0)
                    .contentShape(.dragPreview, shape)
            } moveAction: { from, to in
                print("move from \(from) to \(to)")
                var updatedTasks = entry.tasks.sorted(using: KeyPathComparator(\.index))
                updatedTasks.move(fromOffsets: from, toOffset: to)
                for (index, task) in updatedTasks.enumerated() {
                    task.index = index
                }
            }
        }
        .reorderableForEachContainer(active: $active)
        .onAppear {
            if entry.tasks.isEmpty {
                let newTask = WeeklyTask(
                    icon: IconOptions.todo.rawValue,
                    label: "",
                    index: 0
                )
                entry.tasks.append(newTask)
            }
        }
    }


    var shape: some Shape {
        RoundedRectangle(cornerRadius: 8)
    }
}

#Preview {
    NestedTasksView(entry: .preview)
        .previewSetup()
}
