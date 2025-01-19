//
//  ModelContainer.swift
//  weekly
//
//  Created by Stef Kors on 16/01/2025.
//


import Foundation
import SwiftData

extension ModelContainer {
    static var previews: ModelContainer = {
        let schema = Schema([
            WeeklyEntry.self,
            WeeklyTask.self,
        ])
        let modelConfiguration = ModelConfiguration("MergeRequests", schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    static var shared: ModelContainer = {
        let schema = Schema([
            WeeklyEntry.self,
            WeeklyTask.self,
        ])
        let modelConfiguration = ModelConfiguration("MergeRequests", schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
