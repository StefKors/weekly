//
//  PreviewSetup.swift
//  weekly
//
//  Created by Stef Kors on 19/01/2025.
//

import SwiftUI


extension View {
    func previewSetup(padding: Bool = true) -> some View {
        modifier(PreviewSetup(padding: padding))
    }
}

struct PreviewSetup: ViewModifier {
    var padding: Bool = true
    func body(content: Content) -> some View {
        if padding {
            content
                .modelContainer(.shared)
                .fontDesign(.rounded)
                .scenePadding()
        } else {
            content
                .modelContainer(.shared)
                .fontDesign(.rounded)
        }
    }
}

#Preview {
    Text("Hello, world!")
        .modifier(PreviewSetup())
}
