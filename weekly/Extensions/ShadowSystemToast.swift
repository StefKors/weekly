//
//  ShadowSystemToast.swift
//  weekly
//
//  Created by Stef Kors on 17/01/2025.
//

import SwiftUI

public enum ShadowSystem: String, CaseIterable, Identifiable {
    case toast
    case card
    case cardLarge
    case reduced

    public var id: String {
        return self.rawValue
    }
}

private struct ShadowSystemToast: ViewModifier {
  func body(content: Content) -> some View {
    content
      .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
      .shadow(color: .black.opacity(0.02), radius: 16, x: 0, y: 2)
      .shadow(color: .black.opacity(0.08), radius: 26, x: 0, y: 2)
  }
}

private struct ShadowSystemCardDefault: ViewModifier {
  func body(content: Content) -> some View {
    content
      .shadow(color: .black.opacity(0.02), radius: 3, x: 0, y: 2)
      .shadow(color: .black.opacity(0.02), radius: 9, x: 0, y: 2)
      .shadow(color: .black.opacity(0.02), radius: 19, x: 0, y: 0)
  }
}

private struct ShadowSystemCardLarge: ViewModifier {
  func body(content: Content) -> some View {
    content
      .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 2)
      .shadow(color: .black.opacity(0.02), radius: 10, x: 0, y: 2)
      .shadow(color: .black.opacity(0.06), radius: 40, x: 0, y: 4)
  }
}

private struct ShadowSystemReduced: ViewModifier {
  func body(content: Content) -> some View {
    content
      .shadow(color: .black.opacity(0.04), radius: 2.86286, x: 0, y: 1.90857)
      .shadow(color: .black.opacity(0.02), radius: 9.54286, x: 0, y: 1.90857)
      .shadow(color: .black.opacity(0.06), radius: 38.17143, x: 0, y: 3.81714)
  }
}

extension View {
  @ViewBuilder public func shadow(_ style: ShadowSystem) -> some View {
    switch style {
    case .toast:
      modifier(ShadowSystemToast())
    case .card:
      modifier(ShadowSystemCardDefault())
    case .cardLarge:
      modifier(ShadowSystemCardLarge())
    case .reduced:
      modifier(ShadowSystemReduced())
    }
  }
}

#Preview {
    RoundedRectangle(cornerRadius: 8).background(.secondary)
    .ignoresSafeArea()
    .overlay(alignment: .center) {
      VStack {
        ForEach(ShadowSystem.allCases) { style in
          Text(style.rawValue)
            .padding()
            .padding(.horizontal)
            .background(.blue, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .frame(width: 200, height: 60)
            .shadow(style)
        }
      }
    }
}
