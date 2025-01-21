//
//  CreateActionsView.swift
//  weekly
//
//  Created by Stef Kors on 19/01/2025.
//

import SwiftUI
import SwiftData

struct CreateActionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeeklyEntry.timestamp, order: .forward) private var entries: [WeeklyEntry]

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal) {
                HStack {
                    Button {
                        addDaily()
                    } label: {
                        Label("EOD Update", systemImage: "plus")
                    }

                    Button {
                        addWeekly()
                    } label: {
                        Label("Weekly Update", systemImage: "plus")
                    }

                    Button {
                        //                            addItem()
                    } label: {
                        Label("iOS Release Notes", systemImage: "plus")
                    }
                    .disabled(true)
                }
                .scrollBounceBehavior(.basedOnSize)
                .padding(.leading, 24)
                .padding(.bottom)
                .scrollIndicators(.hidden)
            }
        }
        .buttonStyle(.menubar)
        .opacity(0.6)
    }

    private func addDaily() {
        withAnimation {
            if let lastEntry = entries.last {
                // find tasks from last day and transfer them to new day
                var unfinishedTasks = lastEntry.tasks.filter { task in
                    IconOptions(rawValue: task.icon) != .check
                }

                if unfinishedTasks.isEmpty {
                    unfinishedTasks.append(.preview)
                }

                let newItem = WeeklyEntry(type: .daily, tasks: unfinishedTasks)
                modelContext.insert(newItem)
            }
        }
    }

    private func addWeekly() {
        withAnimation {
            let lastWeeksTasks = tasksFromLastWeek()
            let newItem = WeeklyEntry(type: .weekly, tasks: lastWeeksTasks)
            modelContext.insert(newItem)
        }
    }

    private func tasksFromLastWeek() -> [WeeklyTask] {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!

        // Filter entries within the last week and combine their tasks
        let recentTasks = entries
            .filter { $0.timestamp >= oneWeekAgo }
            .flatMap { $0.tasks }
            .filter { !$0.label.isEmpty } // Filter out tasks with an empty label

        let groupedTasks = Dictionary(grouping: recentTasks) { task in
            IconOptions(rawValue: task.icon) ?? .todo
        }

        var tasksInOrder: [WeeklyTask] = []
        for option in IconOptions.allCases {
            let tasks = groupedTasks[option] ?? []
            for task in tasks {
                tasksInOrder.append(WeeklyTask(icon: task.icon, label: task.label, indent: task.indent))
            }
        }

        return tasksInOrder
    }

    private func deleteItem(_ entry: WeeklyEntry) {
        withAnimation {
            modelContext.delete(entry)
        }
    }
}

#Preview {
    CreateActionsView()
        .previewSetup()
}
