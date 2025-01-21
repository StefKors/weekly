//
//  FetchDescriptor.swift
//  weekly
//
//  Created by Stef Kors on 21/01/2025.
//

import SwiftUI
import SwiftData

extension FetchDescriptor {
    static var today: FetchDescriptor<WeeklyEntry> {
        var fetchDescriptor = FetchDescriptor<WeeklyEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        fetchDescriptor.fetchLimit = 1
        return fetchDescriptor
    }
}
