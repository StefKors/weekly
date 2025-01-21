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
            Text(entry.timestamp.formatted(date: .complete, time: .omitted))
        }
        .font(.title)
        .fontWeight(.bold)
        .padding(.leading, 24)
        .overlay(alignment: .leading) {
            if entry.type == .weekly {
                Circle().fill(.red)
                    .frame(width: 8, height: 8)
                    .offset(x: -4)
            }
        }
    }
}

#Preview {
    TitleEntryView(entry: .preview)
}
