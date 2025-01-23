//
//  WeeklyTaskView.swift
//  weekly
//
//  Created by Stef Kors on 17/01/2025.
//


import SwiftUI
import SwiftData

struct GrabberView: View {
    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 2)

            RoundedRectangle(cornerRadius: 4)
                .frame(width: 2)
        }
        .padding(.vertical, 2)
        .padding(.leading, 4)
        .foregroundStyle(.tertiary)
        .frame(height: 19)
        .contentShape(Rectangle())
    }
}

#Preview {
    GrabberView()
        .scenePadding()
}

struct WeeklyTaskView: View {
    let task: WeeklyTask

    @State private var isHovering: Bool = false

    var body: some View {
        HStack(alignment: .top) {
            HStack() {
                GrabberView()
                    .opacity(isHovering ? 0.4 : 0)
                    .contentShape(shape)
                    .onHover { hoverState in
                        isHovering = hoverState
                    }
                WeeklyTaskEditIcon(task: task)
            }
            .zIndex(2)
            WeeklyTaskEditField(task: task)
                .padding(.vertical, 4)
                .zIndex(1)
        }
        .contentShape(shape)
    }


    var shape: some InsettableShape {
        RoundedRectangle(cornerRadius: 4)
    }
}

#Preview {
    WeeklyTaskView(task: .preview)
}
