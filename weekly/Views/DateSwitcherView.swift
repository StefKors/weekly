//
//  DateSwitcherView.swift
//  weekly
//
//  Created by Stef Kors on 23/01/2025.
//


import SwiftUI

struct DateSwitcherDayTileView: View {
    let date: Date
    @Binding var selectedDate: Date
    var space: Namespace.ID
    var entries: [WeeklyEntry] = []

    /// For date comparisons (e.g., same day).
    private let calendar = Calendar.current

    /// Indicates whether `date` is today or a day in the past.
    private var isTodayOrBefore: Bool {
        let startOfDate = calendar.startOfDay(for: date)
        let startOfToday = calendar.startOfDay(for: Date())
        return startOfDate <= startOfToday
    }

    /// The abbreviated weekday string, e.g. “Mon,” “Tue.”
    private var weekday: String {
        date.formatted(.dateTime.weekday(.abbreviated))
    }

    /// The day number string, e.g. “23,” “24.”
    private var dayNumber: String {
        date.formatted(.dateTime.day())
    }

    /// Checks if this date is the selected date.
    private var isSelected: Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }

    var body: some View {
        // Show “Tue 28”, “Wed 29”, etc.
        VStack(spacing: 2) {
            Text(weekday)
                .font(.caption2)
                .fontWeight(.medium)
            Text(dayNumber)
                .font(.footnote)
                .fontWeight(.semibold)

            HStack(spacing: 4) {
                ForEach(entries) { entry in
                    if entry.hasTasks() {
                        Circle()
                            .fill(.foreground)
                            .frame(width: 4, height: 4, alignment: .center)
                            .foregroundStyle(entry.isWeekly ? AnyShapeStyle(.red) : AnyShapeStyle(.primary))
                    }
                }
            }
        }
        .foregroundColor(isSelected || isTodayOrBefore ? .primary : .secondary)
        .frame(width: 40, height: 52)
        .background {
            if isSelected {
                // Selected date has a dark background (e.g., circle or rounded rectangle).
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.background.quinary)
                    .matchedGeometryEffect(id: "DateBackground", in: space)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.snappy(duration: 0.2)) {
                // Update the selected date when tapped.
                selectedDate = date
            }
        }
    }
}

struct DateSwitcherView: View {
    /// A list of dates to display.
    let dates: [Date]

    /// The currently selected date.
    @Binding var selectedDate: Date

    /// For date comparisons (e.g., same day).
    private let calendar = Calendar.current

    @Namespace private var animation

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(dates, id: \.self) { date in
                    DateSwitcherDayTileView(
                        date: date,
                        selectedDate: $selectedDate,
                        space: animation
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

    }
}

// Example usage
struct ContainerDateSwitcherView: View {
    @State private var selectedDate = Date()

    /// Build a list of dates from a far‐past start date up to *today*.
    var pastDates: [Date] {
        let calendar = Calendar.current
        // Collect every day up to *endDate*
        let today = calendar.startOfDay(for: Date())
        let dates = (-60..<3).compactMap {
            calendar.date(byAdding: .day, value: $0, to: today)
        }

        return dates
    }

    var body: some View {
        VStack {
            DateSwitcherView(dates: pastDates, selectedDate: $selectedDate)
                .padding(.vertical)

            Text("Selected Date: \(selectedDate, style: .date)")
                .font(.headline)
                .padding()
        }
    }
}

#Preview {
    ContainerDateSwitcherView()
        .previewSetup()
}
