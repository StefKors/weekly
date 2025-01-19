//
//  TitleEntryView.swift
//  weekly
//
//  Created by Stef Kors on 17/01/2025.
//

import SwiftUI
import SwiftData

struct TitleEntryView: View {
    let entry: WeeklyEntry

    var body: some View {
        HStack {
            Text(entry.timestamp, style: .date)
        }
        .font(.title)
        .fontWeight(.bold)
        .padding(.leading, 24)
    }
}

#Preview {
    TitleEntryView(entry: .preview)
}
