//
//  weeklyApp.swift
//  weekly
//
//  Created by Stef Kors on 16/01/2025.
//

import SwiftUI
import SwiftData
import Combine
import Observation

extension EnvironmentValues {
    @Entry var entry: WeeklyEntry = .preview
    @Entry var focus: AppFocus = AppFocus()
}

enum ViewFocusable: Hashable {
    case entry(Int)
    case task(UUID)
}

@Observable class AppFocus {
    var focusedView: ViewFocusable?
}

@main
struct weeklyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WeeklyEntry.self,
            WeeklyTask.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var focus: AppFocus = AppFocus()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .fontDesign(.rounded)
                .environment(\.focus, focus)
        }
        .modelContainer(.shared)
        .commands {
            TextEditingCommands()
            TextFormattingCommands()
            ToolbarCommands()
        }
    }
}
