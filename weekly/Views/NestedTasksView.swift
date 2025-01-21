//
//  NestedTasksView.swift
//  weekly
//
//  Created by Stef Kors on 17/01/2025.
//

import SwiftUI
import SwiftData

extension Collection where Element: Equatable {

    func element(after element: Element, wrapping: Bool = false) -> Element? {
        if let index = self.firstIndex(of: element){
            let followingIndex = self.index(after: index)
            if followingIndex < self.endIndex {
                return self[followingIndex]
            } else if wrapping {
                return self[self.startIndex]
            }
        }
        return nil
    }
}

extension BidirectionalCollection where Element: Equatable {

    func element(before element: Element, wrapping: Bool = false) -> Element? {
        if let index = self.firstIndex(of: element){
            let precedingIndex = self.index(before: index)
            if precedingIndex >= self.startIndex {
                return self[precedingIndex]
            } else if wrapping {
                return self[self.index(before: self.endIndex)]
            }
        }
        return nil
    }
}

struct NestedTasksView: View {
    @Bindable var entry: WeeklyEntry

    @State private var active: WeeklyTask?

    @Environment(\.focus) private var focus

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ReorderableForEach(entry.tasks, active: $active) { item in
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
                // TODO Fix moving
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
