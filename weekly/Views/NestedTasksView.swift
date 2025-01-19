//
//  NestedTasksView.swift
//  weekly
//
//  Created by Stef Kors on 17/01/2025.
//

import SwiftUI
import SwiftData

struct NestedTasksView: View {
//    var tasks: [WeeklyTask]
    @Bindable var entry: WeeklyEntry

    @State
    private var active: WeeklyTask?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ReorderableForEach(entry.tasks, active: $active) { item in
                WeeklyTaskView(task: item)
                .padding(.leading, item.indent * 12)
            } preview: { item in
                WeeklyTaskView(task: item)
                    .opacity(0)
                    .contentShape(.dragPreview, shape)
            } moveAction: { from, to in
                print("move from \(from) to \(to)")
                entry.tasks.move(fromOffsets: from, toOffset: to)
            }
        }
        .reorderableForEachContainer(active: $active)
        .onAppear {
            if entry.tasks.isEmpty {
                let newTask = WeeklyTask(
                    icon: IconOptions.todo.rawValue,
                    label: ""
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
        .fontDesign(.rounded)
}
