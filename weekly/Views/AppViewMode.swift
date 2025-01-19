//
//  AppViewMode.swift
//  weekly
//
//  Created by Stef Kors on 19/01/2025.
//


import SwiftUI
import SwiftData

enum AppViewMode: String, Hashable, Identifiable, CaseIterable {
    case today
    case list
    case stack

    var id: String {
        self.rawValue
    }
}

struct ToolbarViewModeToggle: View {
    @Binding var viewMode: AppViewMode

    var body: some View {
        Picker("ViewMode", selection: $viewMode) {
            ForEach(AppViewMode.allCases) { mode in
                Text(mode.rawValue.capitalized).tag(mode)
            }
        }
        .pickerStyle(.segmented)
//        .frame(maxWidth: 10)
    }
}

#Preview {
    ToolbarViewModeToggle(viewMode: .constant(.list))
        .scenePadding()
}
