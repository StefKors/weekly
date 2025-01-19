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
            let newItem = WeeklyEntry(type: .daily, tasks: [.preview])
            modelContext.insert(newItem)
        }
    }

    private func addWeekly() {
        withAnimation {
            let newItem = WeeklyEntry(type: .weekly, tasks: [.preview])
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
    CreateActionsView()
        .previewSetup()
}
