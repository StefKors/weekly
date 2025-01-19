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
    enum FocusField: Hashable {
        case field
    }
    @FocusState private var focusedField: FocusField?

    var body: some View {
        TextField("Weekly Task", text: $task.label)
            .writingToolsBehavior(.complete)
            .textFieldStyle(.plain)
            .focused($focusedField, equals: .field)
//            .onAppear {
//                DispatchQueue.main.asyncAfter(deadline: .now()) {
//                    self.focusedField = .field
//                }
//            }
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
            label: ""
        )
        guard let currentIndex = entry.tasks.firstIndex(of: task) else {
            withAnimation(.snappy(duration: 0.2)) {
                entry.tasks.append(newTask)
            }
            return
        }
        withAnimation(.snappy(duration: 0.2)) {
            // insert at index
            entry.tasks.insert(newTask, at: currentIndex + 1)
        }
    }

    func onDelete() {
        withAnimation(.snappy(duration: 0.2)) {
            entry.tasks.removeAll(where: { item in
                return item === task
            })
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
