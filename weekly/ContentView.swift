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
    }
}

#Preview {
    ContentView()
        .modelContainer(.shared)
        .fontDesign(.rounded)
}
