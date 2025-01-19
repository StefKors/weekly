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
struct TodayAppView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(.today) private var entries: [WeeklyEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .center) {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading) {
                            TitleEntryView(entry: entry)
                            NestedTasksView(entry: entry)
                                .environment(\.entry, entry)
                        }
                        .frame(maxWidth: 400, alignment: .leading)
                        .scenePadding(.vertical)
                        .contextMenu {
                            Button {
                                entry.copyToPasteboard()
                            } label: {
                                Label("Copy to Slack", systemImage: "document.on.document")
                            }

                            Divider()

                            Button {
                                deleteItem(entry)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .scrollBounceBehavior(.basedOnSize)
            }
            .contentMargins(.bottom, 40, for: .scrollContent)
        }
        .fadeMask(alignment: .bottom, size: 20, startingAt: 40)
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading) {
                ScrollView(.horizontal) {
                    HStack {
                        Button {
                            addItem()
                        } label: {
                            Label("EOD Update", systemImage: "plus")
                        }

                        Button {
                            addItem()
                        } label: {
                            Label("Weekly Update", systemImage: "plus")
                        }
                        .disabled(true)

                        Button {
                            addItem()
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
    }

    private func addItem() {
        withAnimation {
            let newItem = WeeklyEntry(tasks: [.preview])
            modelContext.insert(newItem)
        }
    }

    private func deleteItem(_ entry: WeeklyEntry) {
        withAnimation {
            modelContext.delete(entry)
        }
    }
}

#Preview {
    TodayAppView()
        .previewSetup()
}
