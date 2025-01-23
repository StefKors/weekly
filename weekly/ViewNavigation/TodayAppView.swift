//
//  TodayAppView.swift
//  weekly
//
//  Created by Stef Kors on 19/01/2025.
//


import SwiftUI
import SwiftData

struct TodayAppView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeeklyEntry.timestamp, order: .forward) private var entries: [WeeklyEntry]

    @State private var selectedEntry: WeeklyEntry? = nil
    @Environment(\.focus) private var focus

    /// Keep track of the currently selected date.
    @State private var selectedDate = Date()
    @State private var selectedDate2 = Date()

    //    /// Track the previous selected date so we can decide
    //    /// which edge to use (leading or trailing).
    //    @State private var previousSelectedDate = Date()

    /// The transition edge we’ll use for `.move(edge: transitionEdge)`.
    @State private var transitionEdge: Edge = .leading

    private let calendar = Calendar.current

    /// Build a list of dates from a far‐past start date up to *today*.
    private var pastDates: [Date] {
        // Collect every day up to *endDate*
        let today = calendar.startOfDay(for: Date())
        let dates = (-60..<3).compactMap {
            calendar.date(byAdding: .day, value: $0, to: today)
        }

        return dates
    }

    private var todaysEntry: WeeklyEntry? {
        entries.first { calendar.isDate($0.timestamp, inSameDayAs: selectedDate2) }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            DateSwitcherView(dates: pastDates, selectedDate: $selectedDate)
                .frame(maxWidth: 400,alignment: .center)


            if let entry = todaysEntry {
                SingleEntryView(entry: entry)
                    .id(entry.id)
                // Use the dynamic transition edge, combining with opacity
                    .transition(.opacity.combined(with: .push(from: transitionEdge)))
                    .task(id: entry.id) {
                        if let task = entry.tasks.last {
                            print("set focus to task \(task.id)")
                            focus.focusedView = .task(task.id)
                        }
                    }
            }
        }
        .scenePadding()
        // Whenever selectedDate changes, figure out if we moved forward or backward in time
        .onChange(of: selectedDate) { previousSelectedDate, newDate in
            if newDate > previousSelectedDate {
                // Going to a *later* date, so slide in from the trailing edge
                transitionEdge = .trailing
            } else if newDate < previousSelectedDate {
                // Going to an *earlier* date, so slide in from the leading edge
                transitionEdge = .leading
            }
            withAnimation(.snappy(duration: 0.2)) {
                selectedDate2 = newDate
            }
        }
        .task(id: todaysEntry) {
            if todaysEntry == nil {
                let isWednesday = calendar.component(.weekday, from: selectedDate) == 4
                let newEntry = WeeklyEntry(timestamp: selectedDate, type: isWednesday ? .weekly : .daily)
                modelContext.insert(newEntry)
                try? modelContext.save()
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
