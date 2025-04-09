//
//  MenuBarButtonStyle.swift
//  weekly
//
//  Created by Stef Kors on 17/01/2025.
//


//
//  MenuBarButtonStyle.swift
//
//
//  Created by Stef Kors on 10/03/2023.
//

import SwiftUI

struct MenuBarButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    var color: Color?
    var size: CGFloat = 44

    func makeBody(configuration: Configuration) -> some View {
        let isMouseDown: Bool = configuration.isPressed || !isEnabled
        GroupBox {
            configuration.label
        }
        .opacity(isMouseDown ? 0.7 : 1)
        .animation(.spring(), value: isMouseDown)
        .foregroundStyle(isEnabled ? .primary : .tertiary)
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        if let color = color {
            return (isPressed || !isEnabled) ? color.opacity(0.5) : color
        }
        return .black.opacity(0.3)
    }
}

extension ButtonStyle where Self == MenuBarButtonStyle {
    static var menubar: Self { MenuBarButtonStyle() }
}

struct MenuBarButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button {
                // action
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                }
            }

            Button {
                // action
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                }
            }
            .disabled(true)
        }
        .font(.system(size: 11))
        .buttonStyle(.menubar)
        .scenePadding()
    }
}
