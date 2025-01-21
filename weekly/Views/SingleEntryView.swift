//
//  SingleEntryView.swift
//  weekly
//
//  Created by Stef Kors on 21/01/2025.
//

import SwiftUI

struct SingleEntryView: View {
    let entry: WeeklyEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        TitleEntryView(entry: entry)
                        NestedTasksView(entry: entry)
                            .environment(\.entry, entry)
                    }
                    .frame(maxWidth: 400, alignment: .leading)
                    .scenePadding(.vertical)
                    .contextMenu {
                        EntryContextMenu(entry: entry)
                    }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .scrollBounceBehavior(.basedOnSize)
        }
        .contentMargins(.bottom, 40, for: .scrollContent)
    }
}

#Preview {
    SingleEntryView(entry: .preview)
        .previewSetup()
}
