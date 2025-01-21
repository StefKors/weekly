//
//  ContentView.swift
//  weekly
//
//  Created by Stef Kors on 16/01/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeeklyEntry.timestamp, order: .forward) private var entries: [WeeklyEntry]

    @State private var searchText: String = ""

    @SceneStorage("viewMode") private var viewMode: AppViewMode = .today

    var body: some View {
        ZStack {
            switch viewMode {
            case .today:
                TodayAppView()
            case .list:
                ListAppView()
            case .stack:
                StackAppView()
            }
        }
        .navigationTitle(Text("#weekly"))
        .searchable(text: $searchText, prompt: "Search...")
        .toolbar {
            ToolbarItem() {
                ToolbarViewModeToggle(viewMode: $viewMode)
            }
        }
        .task {
            print("Running init with mock data")
            if entries.count < 30 {
                let calendar = Calendar.current
                let today = Date()

                for i in 0..<30 {
                    guard let date = calendar.date(byAdding: .day, value: -i, to: today),
                          !calendar.isDateInWeekend(date) else { continue }

                    // Create a daily entry
                    let dailyEntry = WeeklyEntry(
                        timestamp: date,
                        type: .daily,
                        tasks: [.preview]
                    )
                    modelContext.insert(dailyEntry)

                    // Create an extra weekly entry if the day is Wednesday
                    // 4 represents Wednesday
                    if calendar.component(.weekday, from: date) == 4 {
                        let weeklyEntry = WeeklyEntry(
                            timestamp: date,
                            type: .weekly,
                            tasks: [.preview]
                        )
                        modelContext.insert(weeklyEntry)
                    }
                }

            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(.shared)
        .fontDesign(.rounded)
}
