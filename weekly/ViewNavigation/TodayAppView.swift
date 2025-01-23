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
        entries.first { calendar.isDate($0.timestamp, inSameDayAs: selectedDate2) && $0.isDaily }
    }

    private var todaysWeeklyEntry: WeeklyEntry? {
        entries.first { calendar.isDate($0.timestamp, inSameDayAs: selectedDate2) && $0.isWeekly }
    }

    @Namespace private var animation

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(pastDates, id: \.self) { date in
                        let dateEntries = entries.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
                        DateSwitcherDayTileView(
                            date: date,
                            selectedDate: $selectedDate,
                            space: animation,
                            entries: dateEntries
                        )
                    }
                }

            }
            .defaultScrollAnchor(.trailing)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.background)
                    .shadow(.cardLarge)
            }
            .frame(maxWidth: 400,alignment: .center)


            if let entry = todaysEntry {
                SingleEntryView(entry: entry)
                    .id(entry.id)
                    .transition(.opacity.combined(with: .push(from: transitionEdge)))
                    .task(id: entry.id) {
                        if let task = entry.tasks.last {
                            print("set focus to task \(task.id)")
                            focus.focusedView = .task(task.id)
                        }
                    }
                    .toolbar {
                        ToolbarItem() {
                            Button {
                                entry.copyToPasteboard()
                            } label: {
                                Label {
                                    Text("Copy to Slack")
                                } icon: {
                                    Image(.slack)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .grayscale(1)
                                        .frame(width: 20, height: 20, alignment: .center)
                                }
                            }

                        }
                    }
            }

            if let entry = todaysWeeklyEntry {
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
        .frame(maxHeight: .infinity, alignment: .top)
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
                let entryBeforeSelectedDate = entries.filter { entry in
                    // Compare each entry's timestamp with the selected date
                    calendar.compare(entry.timestamp, to: selectedDate, toGranularity: .day) == .orderedAscending && entry.isDaily
                }
                    .sorted { $0.timestamp > $1.timestamp } // Sort in descending order by timestamp
                    .first // Get the most recent one (if it exists)

                let isWednesday = calendar.component(.weekday, from: selectedDate) == 4
                let tasks: [WeeklyTask] = entryBeforeSelectedDate?.tasks.map { .init($0) } ?? []
                let newEntry = WeeklyEntry(
                    timestamp: selectedDate,
                    type: isWednesday ? .weekly : .daily,
                    tasks: tasks
                )

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
