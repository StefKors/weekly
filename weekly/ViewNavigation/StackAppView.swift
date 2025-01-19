//
//  StackAppView.swift
//  weekly
//
//  Created by Stef Kors on 19/01/2025.
//


import SwiftUI
import SwiftData

struct StackAppView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeeklyEntry.timestamp, order: .forward) private var entries: [WeeklyEntry]

    var limitedEntries: [WeeklyEntry] {
        Array(entries.suffix(5))
    }
    var body: some View {
        ZStack(alignment: .center) {
            ZStack(alignment: .top) {
                ForEach(Array(zip(limitedEntries.indices, limitedEntries)), id: \.1) {
                    index,
                    entry in
                    VStack(alignment: .leading) {
                        TitleEntryView(entry: entry)
                        NestedTasksView(entry: entry)
                            .environment(\.entry, entry)
                    }
                    .padding(.vertical)
                    .background(.background, in: RoundedRectangle(cornerRadius: 20))
                    .frame(
                        maxWidth: 400 + ((CGFloat(index) - CGFloat(limitedEntries.count)) * 30),
                        maxHeight: 300,
                        alignment: .top
                    )
                    .shadow(.cardLarge)
                    .offset(y: CGFloat(index) * 20)
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
            .frame(maxWidth: 400, maxHeight: 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
    StackAppView()
        .previewSetup()
}
