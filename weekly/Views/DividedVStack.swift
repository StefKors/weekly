//
//  DividedVStack.swift
//  weekly
//
//  Created by Stef Kors on 16/01/2025.
//



import SwiftUI

/// A vertical stack that adds separators
/// From https://movingparts.io/variadic-views-in-swiftui
struct DividedVStack<Content: View>: View {
  var alignment: HorizontalAlignment
  var spacing: CGFloat?
  var leadingMargin: CGFloat
  var trailingMargin: CGFloat
  var color: Color?
  var content: Content

  public init(
    alignment: HorizontalAlignment = .center,
    spacing: CGFloat? = nil,
    leadingMargin: CGFloat = 0,
    trailingMargin: CGFloat = 0,
    color: Color? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.leadingMargin = leadingMargin
    self.trailingMargin = trailingMargin
    self.color = color
    self.content = content()
  }

  public var body: some View {
    _VariadicView.Tree(
      DividedVStackLayout(
        alignment: alignment,
        spacing: spacing,
        leadingMargin: leadingMargin,
        trailingMargin: trailingMargin,
        color: color
      )
    ) {
      content
    }
  }
}

struct DividedVStackLayout: _VariadicView_UnaryViewRoot {
  var alignment: HorizontalAlignment
  var spacing: CGFloat?
  var leadingMargin: CGFloat
  var trailingMargin: CGFloat
  var color: Color?

  @ViewBuilder
  public func body(children: _VariadicView.Children) -> some View {
    let last = children.last?.id

    VStack(alignment: alignment, spacing: spacing) {
      ForEach(children) { child in
        child

        if child.id != last {
          Divider()
            .foregroundStyle(color ?? .primary)
            .padding(.leading, leadingMargin)
            .padding(.trailing, trailingMargin)
        }
      }
    }
  }
}

/// A horizontal stack that adds separators
struct DividedHStack<Content: View>: View {
  var alignment: VerticalAlignment
  var spacing: CGFloat?
  var topMargin: CGFloat
  var bottomMargin: CGFloat
  var color: Color?
  var content: Content

  public init(
    alignment: VerticalAlignment = .center,
    spacing: CGFloat? = nil,
    topMargin: CGFloat = 0,
    bottomMargin: CGFloat = 0,
    color: Color? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.topMargin = topMargin
    self.bottomMargin = bottomMargin
    self.color = color
    self.content = content()
  }

  public var body: some View {
    _VariadicView.Tree(
      DividedHStackLayout(
        alignment: alignment,
        spacing: spacing,
        topMargin: topMargin,
        bottomMargin: bottomMargin,
        color: color
      )
    ) {
      content
    }
  }
}

struct DividedHStackLayout: _VariadicView_UnaryViewRoot {
  var alignment: VerticalAlignment
  var spacing: CGFloat?
  var topMargin: CGFloat
  var bottomMargin: CGFloat
  var color: Color?

  @ViewBuilder
  public func body(children: _VariadicView.Children) -> some View {
    let last = children.last?.id

    HStack(alignment: alignment, spacing: spacing) {
      ForEach(children) { child in
        child

        if child.id != last {
          Divider()
            .foregroundStyle(color ?? .primary)
            .padding(.top, topMargin)
            .padding(.bottom, bottomMargin)
        }
      }
    }
  }
}

#Preview("Horizontal") {
  let item: some View = Image(systemName: "scribble.variable").padding()
  DividedHStack(color: .red) {
    item
    item
    item
  }
  .frame(maxHeight: 20)
  .scenePadding()
}

#Preview("Vertical") {
  let item: some View = Image(systemName: "scribble.variable").padding()
  DividedVStack(color: .red) {
    item
    item
    item
  }
  .frame(maxWidth: 20)
  .scenePadding()
}
