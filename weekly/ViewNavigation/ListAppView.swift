//
//  ListAppView.swift
//  weekly
//
//  Created by Stef Kors on 19/01/2025.
//


import SwiftUI
import SwiftData

struct EntryContextMenu: View {
    let entry: WeeklyEntry

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Button {
            entry.copyToPasteboard()
        } label: {
            Label("Copy to Slack", systemImage: "document.on.document")
        }

        Menu("Entry Type") {
            ForEach(EntryType.allCases) { type in
                Button {
                    entry.type = type
                } label: {
                    HStack {
                        Text(type.rawValue.capitalized)
                        if entry.type == type {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }

        Divider()

        Button {
            deleteItem(entry)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }


    private func deleteItem(_ entry: WeeklyEntry) {
        withAnimation {
            modelContext.delete(entry)
        }
    }
}

#Preview {
    EntryContextMenu(entry: .preview)
        .previewSetup()
}

struct ListAppView: View {
    @Query(sort: \WeeklyEntry.timestamp, order: .forward) private var entries: [WeeklyEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading) {
                            TitleEntryView(entry: entry)
                            NestedTasksView(entry: entry)
                                .environment(\.entry, entry)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .scenePadding(.vertical)
                        .contextMenu {
                            EntryContextMenu(entry: entry)
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .contentMargins(.bottom, 40, for: .scrollContent)
        }
        .fadeMask(alignment: .bottom, size: 20, startingAt: 40)
        .overlay(alignment: .bottomLeading) {
            CreateActionsView()
        }
    }
}

#Preview {
    ListAppView()
        .previewSetup()
}
