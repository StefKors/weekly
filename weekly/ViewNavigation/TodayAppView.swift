//
//  TodayAppView.swift
//  weekly
//
//  Created by Stef Kors on 19/01/2025.
//


import SwiftUI
import SwiftData

extension FetchDescriptor {
    static var today: FetchDescriptor<WeeklyEntry> {
        var fetchDescriptor = FetchDescriptor<WeeklyEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        fetchDescriptor.fetchLimit = 1
        return fetchDescriptor
    }
}

struct SingleEntryView: View {
    let entry: WeeklyEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {

                    VStack(alignment: .leading) {
                        TitleEntryView(entry: entry)
                        NestedTasksView(entry: entry)
                            .environment(\.entry, entry)
                    }
                    .frame(maxWidth: 400, alignment: .leading)
                    .scenePadding(.vertical)
                    .contextMenu {
                        EntryContextMenu(entry: entry)
                    }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .scrollBounceBehavior(.basedOnSize)
        }
        .contentMargins(.bottom, 40, for: .scrollContent)
    }
}

#Preview {
    SingleEntryView(entry: .preview)
        .previewSetup()
}

struct TodayAppView: View {
//    @Query(.today) private var entries: [WeeklyEntry]
    @Query(sort: \WeeklyEntry.timestamp, order: .forward) private var entries: [WeeklyEntry]

    @State private var selectedEntry: WeeklyEntry? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let entry = selectedEntry ?? entries.last {
                SingleEntryView(entry: entry)
                    .id(entry.id)
                    .transition(.opacity.combined(with: .slide))
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
