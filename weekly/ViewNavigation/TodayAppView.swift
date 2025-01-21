//
//  TodayAppView.swift
//  weekly
//
//  Created by Stef Kors on 19/01/2025.
//


import SwiftUI
import SwiftData

struct TodayAppView: View {
    @Query(sort: \WeeklyEntry.timestamp, order: .forward) private var entries: [WeeklyEntry]

    @State private var selectedEntry: WeeklyEntry? = nil
    @Environment(\.focus) private var focus

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let entry = selectedEntry ?? entries.last {
                SingleEntryView(entry: entry)
                    .id(entry.id)
                    .transition(.opacity.combined(with: .slide))
                    .task(id: entry.id) {
                        if let task = entry.tasks.last {
                            print("set focus to task \(task.id)")
                            focus.focusedView = .task(task.id)
                        }
                    }
            }

            EntryTimelineView(selectedEntry: $selectedEntry)
                .padding(.bottom, 50)
                .task {
                    if selectedEntry == nil {
                        selectedEntry = entries.last
                    }
                }
        }
        .fadeMask(alignment: .bottom, size: 20, startingAt: 40)
        .overlay(alignment: .bottomLeading) {
            CreateActionsView()
        }
    }
}

#Preview {
    TodayAppView()
        .previewSetup()
}
