//
//  EntryTimelineView.swift
//  weekly
//
//  Created by Stef Kors on 19/01/2025.
//

import SwiftUI
import SwiftData


struct EntryTimelineView: View {
    @Binding var selectedEntry: WeeklyEntry?

    @Query(sort: \WeeklyEntry.timestamp, order: .forward) private var entries: [WeeklyEntry]

    @Namespace private var activeEntryNamespace

    var body: some View {

        GeometryReader { proxy in
            HStack(alignment: .bottom, spacing: 0) {
                //            ScrollView(.horizontal) {
                ForEach(entries) { entry in
                    TimelineEntryView(
                        selectedEntry: selectedEntry,
                        namespace: activeEntryNamespace,
                        entry: entry
                    )
                        .onTapGesture {
                            withAnimation(.smooth(duration: 0.2)) {
                                selectedEntry = entry
                            }
                        }
                }
            }
            .frame(width: proxy.size.width/2, alignment: .trailing)
        }
        .frame(height: 140)
    }
}

#Preview {
    EntryTimelineView(selectedEntry: .constant(nil))
        .frame(width: 500, height: 600)
        .previewSetup()
}

struct TimelineEntryView: View {
    var selectedEntry: WeeklyEntry?
    let namespace: Namespace.ID
    let entry: WeeklyEntry

    @State private var isHovering: Bool = false

    var body: some View {
        VStack {
            if entry.type == .weekly {
                if selectedEntry == entry || isHovering {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.red)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.tertiary)
                }
            } else {
                if selectedEntry == entry || isHovering {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.primary)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.tertiary)
                }
            }
        }
        .frame(width: 2, height: min(100, CGFloat(entry.tasks.count) * 10), alignment: .bottom)
        .padding(.horizontal, 6)
        .contentShape(Rectangle())
        .overlay(alignment: .top) {
            if isHovering {
                Text(entry.timestamp, style: .date)
                    .fixedSize()
                    .allowsHitTesting(false)
                //                    .transition(.opacity)
                    .matchedGeometryEffect(id: "title", in: namespace)
            }
        }
        .onHover { hoverState in
            withAnimation(.smooth(duration: 0.2)) {
                isHovering = hoverState
            }
        }
    }
}
