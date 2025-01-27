//
//  WeeklyTaskEditField.swift
//  weekly
//
//  Created by Stef Kors on 17/01/2025.
//

import SwiftUI
import SwiftData

struct WeeklyTaskEditField: View {
    @Bindable var task: WeeklyTask
    var onCommit: () -> Void = { }

    @Environment(\.entry) private var entry
    @Environment(\.focus) private var focus

    enum FocusField: Hashable {
        case field
    }
    @FocusState private var focusedField: FocusField?

    var body: some View {
        TextField("Weekly Task", text: $task.label, axis: .vertical)
            .writingToolsBehavior(.complete)
            .textFieldStyle(.plain)
            .focused($focusedField, equals: .field)
            .task(id: focus.focusedView) {
                if case .task(let id) = focus.focusedView {
                    if id == task.id {
                        focusedField = .field
                    }
                }
            }
            .onKeyPress(action: { keyPress in
                if keyPress.characters == "]" && keyPress.modifiers.contains(.command) {
                    onIncreaseIndent()
                    return .handled
                }

                if keyPress.characters == "[" && keyPress.modifiers.contains(.command) {
                    onDecreaseIndent()
                    return .handled
                }

                switch keyPress.key {
                case .DEL, .backspace:
                    if task.label.isEmpty {
                        if task.indent > 0 {
                            onDecreaseIndent()
                        } else {
                            onDelete()
                        }
                        return .handled
                    } else {
                        return .ignored
                    }
                case .delete, .deleteForward:
                    onDelete()
                    return .handled
                case .tab:
                    onIncreaseIndent()
                    return .handled
                case .return:
                    onReturnKey()
                    return .handled
                default:
                    return .ignored
                }
            })
            .onSubmit(of: .text, {
                onReturnKey()
            })
            .submitScope()
            .scrollContentBackground(.hidden)
            .multilineTextAlignment(.leading)
    }

    func onReturnKey() {
        let newTask = WeeklyTask(
            icon: IconOptions.todo.rawValue,
            label: "",
            index: entry.tasks.count
        )
        withAnimation(.snappy(duration: 0.2)) {
            // insert at index
            var tasks = entry.tasks.sorted { $0.index < $1.index }
            if let currentIndex = tasks.firstIndex(of: task) {
                newTask.index = currentIndex + 1
                tasks.insert(newTask, at: currentIndex + 1)
            } else {
                tasks.append(newTask)
            }

            entry.tasks = tasks
            focus.focusedView = .task(newTask.id)
        }
    }

    func onDelete() {
        var tasks = entry.tasks.sorted { $0.index < $1.index }
        let taskBefore = tasks.element(before: task)
        if let taskBefore {
            focus.focusedView = .task(taskBefore.id)
        }
        withAnimation(.snappy(duration: 0.2)) {
            tasks.removeAll(where: { item in
                return item === task
            })
            entry.tasks = tasks
        }
    }

    func onDecreaseIndent() {
        task.indent = max(0, task.indent - 1)
    }

    func onIncreaseIndent() {
        task.indent = max(0, task.indent + 1)
    }
}

#Preview {
    WeeklyTaskEditField(task: .preview)
        .scenePadding()
}
