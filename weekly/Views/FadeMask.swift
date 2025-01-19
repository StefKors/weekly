//
//  FadeMask.swift
//  weekly
//
//  Created by Stef Kors on 17/01/2025.
//

import SwiftUI

private struct FadeMask: View {
    /// Axis to fade
    var alignment: Edge.Set = .horizontal
    /// number between 0 and 1 as percentage of distance to cover half of distance
    var distance: CGFloat = 0.4
    /// Minimum size of fade in pixels
    var minSize: CGFloat = 60

    private var shape: some Shape {
        ContainerRelativeShape()
    }

    private var stops: [Gradient.Stop] {
        [
            Gradient.Stop(color: .white, location: 0),
            Gradient.Stop(color: .white, location: 1 - distance),
            Gradient.Stop(color: .black, location: 1)
        ]
    }

    private var trailingFade: some View {
        shape
            .fill(LinearGradient(stops: stops, startPoint: .leading, endPoint: .trailing))
            .frame(minWidth: minSize)
    }

    private var leadingFade: some View {
        shape
            .fill(LinearGradient(stops: stops, startPoint: .trailing, endPoint: .leading))
            .frame(minWidth: minSize)
    }

    private var topFade: some View {
        shape
            .fill(LinearGradient(stops: stops, startPoint: .bottom, endPoint: .top))
            .frame(minHeight: minSize)
    }

    private var bottomFade: some View {
        shape
            .fill(LinearGradient(stops: stops, startPoint: .top, endPoint: .bottom))
            .frame(minHeight: minSize)
    }

    private var noFade: some View {
        shape
            .fill(Color.white)
    }

    var body: some View {
        ZStack {
            switch alignment {
            case .horizontal:
                HStack(spacing: 0) {
                    leadingFade
                    Rectangle().fill(.white)
                    trailingFade
                }
            case .vertical:
                VStack(spacing: 0) {
                    topFade
                    Rectangle().fill(.white)
                    bottomFade
                }
            case .leading:
                HStack(spacing: 0) {
                    leadingFade
                    noFade
                }
            case .trailing:
                HStack(spacing: 0) {
                    noFade
                    trailingFade
                }
            case .top:
                VStack(spacing: 0) {
                    topFade
                    noFade
                }
            case .bottom:
                VStack(spacing: 0) {
                    noFade
                    bottomFade
                }
            default:
                // nothing
                noFade
            }
        }
        .compositingGroup()
        .luminanceToAlpha()
    }
}

private struct FadeMaskModifier: ViewModifier {
    var alignment: Edge.Set = .horizontal
    var distance: CGFloat = 0.4
    var minSize: CGFloat = 60

    func body(content: Content) -> some View {
        content
            .mask {
                FadeMask(alignment: alignment, distance: distance, minSize: minSize)
            }
    }
}

private struct FadeMaskFixed: View {
    /// Axis to fade
    var alignment: Edge.Set = .horizontal
    /// Size of fade in pixels
    var size: CGFloat = 60
    /// Amount before fade starts
    var startingAt: CGFloat = 0

    private var shape: some Shape {
        ContainerRelativeShape()
    }

    private var stops: [Gradient.Stop] {
        [
            Gradient.Stop(color: .white, location: 0),
//            Gradient.Stop(color: .black, location: 1 - 0.4),
            Gradient.Stop(color: .black, location: 1)
        ]
    }

    private var trailingFade: some View {
        shape
            .fill(LinearGradient(stops: stops, startPoint: .leading, endPoint: .trailing))
            .frame(width: size)
    }

    private var leadingFade: some View {
        shape
            .fill(LinearGradient(stops: stops, startPoint: .trailing, endPoint: .leading))
            .frame(width: size)
    }

    private var topFade: some View {
        shape
            .fill(LinearGradient(stops: stops, startPoint: .bottom, endPoint: .top))
            .frame(height: size)
    }

    private var bottomFade: some View {
        shape
            .fill(LinearGradient(stops: stops, startPoint: .top, endPoint: .bottom))
            .frame(height: size)
    }

    private var noFade: some View {
        shape
            .fill(Color.white)
    }

    var body: some View {
        ZStack {
            switch alignment {
            case .horizontal:
                HStack(spacing: 0) {
                    Rectangle().fill(.black).frame(width: startingAt)
                    leadingFade
                    Rectangle().fill(.white)
                    trailingFade
                    Rectangle().fill(.black).frame(width: startingAt)
                }
            case .vertical:
                VStack(spacing: 0) {
                    Rectangle().fill(.black).frame(height: startingAt)
                    topFade
                    Rectangle().fill(.white)
                    bottomFade
                    Rectangle().fill(.black).frame(height: startingAt)
                }
            case .leading:
                HStack(spacing: 0) {
                    Rectangle().fill(.black).frame(width: startingAt)
                    leadingFade
                    noFade
                }
            case .trailing:
                HStack(spacing: 0) {
                    noFade
                    trailingFade
                    Rectangle().fill(.black).frame(width: startingAt)
                }
            case .top:
                VStack(spacing: 0) {
                    Rectangle().fill(.black).frame(height: startingAt)
                    topFade
                    noFade
                }
            case .bottom:
                VStack(spacing: 0) {
                    noFade
                    bottomFade
                    Rectangle().fill(.black).frame(height: startingAt)
                }
            default:
                // nothing
                noFade
            }
        }
        .compositingGroup()
        .luminanceToAlpha()
    }
}

private struct FadeMaskFixedModifier: ViewModifier {
    var alignment: Edge.Set = .horizontal
    var size: CGFloat = 600
    var startingAt: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .mask {
                FadeMaskFixed(alignment: alignment, size: size, startingAt: startingAt)
            }
    }
}

extension View {
    /// Gradient fade to fade out view
    /// - Parameters:
    ///   - alignment: Axis to fade
    ///   - distance: Percentage of half the axis to fade
    ///   - minSize: Minimum size of fade in pixels
    /// - Returns: masked view
    func fadeMask(alignment: Edge.Set, distance: CGFloat = 1, minSize: CGFloat = 60) -> some View {
        modifier(FadeMaskModifier(alignment: alignment, distance: distance, minSize: minSize))
    }

    /// Gradient fade to fade out view
    /// - Parameters:
    ///   - alignment: Axis to fade
    ///   - size: Size of fade in pixels
    ///   - startingAt: Amount before fade starts
    /// - Returns: masked view
    func fadeMask(alignment: Edge.Set, size: CGFloat, startingAt: CGFloat = 0) -> some View {
        modifier(FadeMaskFixedModifier(alignment: alignment, size: size, startingAt: startingAt))
    }
}

#Preview("FadeMask - Large") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Nice Title")
            .font(.title)
            .bold()
        Text("A paragraph (from Ancient Greek παράγραφος (parágraphos) 'to write beside') is a self-contained unit of discourse in writing dealing with a particular point or idea. Though not required by the orthographic conventions of any language with a writing system, paragraphs are a conventional means of organizing extended segments of prose. ")
    }
    .fadeMask(alignment: .bottom, distance: 1)
    .frame(maxWidth: 300)
    .scenePadding()
}

#Preview("FadeMask - Small") {
    VStack(alignment: .leading, spacing: 16) {
        Text("A single line")
    }
    .fadeMask(alignment: .bottom, distance: 1)
    .border(Color.red)
    .frame(maxWidth: 300)
    .scenePadding()
}

#Preview {
    ZStack {
        Color.black
        Rectangle()
            .fill(.thickMaterial)
            .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .frame(maxWidth: 320)
            .shadow(.cardLarge)
            .padding(.horizontal)
    }.ignoresSafeArea()
}

#Preview("FadeMask - Fixed") {
    ZStack {
        Color.black

        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.blue)
            // fixed size fade mask
                .fadeMask(alignment: .bottom, size: 200)

            // demo grid lines to explain size
            VStack(alignment: .leading, spacing: 0) {
                Text("height: 0px")
                    .foregroundStyle(.purple)
                    .padding(4)
                Rectangle().fill(.purple).frame(height: 1)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text("height: 100px")
                    .foregroundStyle(.purple)
                    .padding(4)
                Rectangle().fill(.purple).frame(height: 1)
                Rectangle()
                    .fill(.clear)
                    .frame(height: 100)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text("height: 200px")
                    .foregroundStyle(.purple)
                    .padding(4)
                Rectangle().fill(.purple).frame(height: 1)
                Rectangle()
                    .fill(.clear)
                    .frame(height: 200)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text("height: 300px")
                    .foregroundStyle(.purple)
                    .padding(4)
                Rectangle().fill(.purple).frame(height: 1)
                Rectangle()
                    .fill(.clear)
                    .frame(height: 300)
            }
        }
        .font(.caption2)
        .fontWeight(.bold)
        .background(.thickMaterial)
        .frame(maxWidth: 300, maxHeight: 500)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .shadow(.cardLarge)
        .padding()

    }
    .ignoresSafeArea()
}

#Preview("FadeMask - Fixed Start Offset") {
    ZStack {
        Color.black
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.blue)
            // fixed size fade mask
                .fadeMask(alignment: .bottom, size: 200, startingAt: 100)

            // demo grid lines to explain size
            VStack(alignment: .leading, spacing: 0) {
                Text("height: 0px")
                    .foregroundStyle(.purple)
                    .padding(4)
                Rectangle().fill(.purple).frame(height: 1)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text("height: 100px")
                    .foregroundStyle(.purple)
                    .padding(4)
                Rectangle().fill(.purple).frame(height: 1)
                Rectangle()
                    .fill(.clear)
                    .frame(height: 100)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text("height: 200px")
                    .foregroundStyle(.purple)
                    .padding(4)
                Rectangle().fill(.purple).frame(height: 1)
                Rectangle()
                    .fill(.clear)
                    .frame(height: 200)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text("height: 300px")
                    .foregroundStyle(.purple)
                    .padding(4)
                Rectangle().fill(.purple).frame(height: 1)
                Rectangle()
                    .fill(.clear)
                    .frame(height: 300)
            }
        }
        .font(.caption2)
        .fontWeight(.bold)
        .background(.thickMaterial)
        .frame(maxWidth: 300, maxHeight: 500)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .shadow(.cardLarge)
        .padding()

    }
    .ignoresSafeArea()
}

#Preview("FadeMask - Fixed Vertical Offset") {
    ZStack {
        Color.black

        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.blue)
            // fixed size fade mask
                .fadeMask(alignment: .vertical, size: 100, startingAt: 100)

            // demo grid lines to explain size
            VStack(alignment: .leading, spacing: 0) {
                Text("height: 0px")
                    .foregroundStyle(.purple)
                    .padding(4)
                Rectangle().fill(.purple).frame(height: 1)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text("height: 100px")
                    .foregroundStyle(.purple)
                    .padding(4)
                Rectangle().fill(.purple).frame(height: 1)
                Rectangle()
                    .fill(.clear)
                    .frame(height: 100)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text("height: 200px")
                    .foregroundStyle(.purple)
                    .padding(4)
                Rectangle().fill(.purple).frame(height: 1)
                Rectangle()
                    .fill(.clear)
                    .frame(height: 200)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text("height: 300px")
                    .foregroundStyle(.purple)
                    .padding(4)
                Rectangle().fill(.purple).frame(height: 1)
                Rectangle()
                    .fill(.clear)
                    .frame(height: 300)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text("height: 400px")
                    .foregroundStyle(.purple)
                    .padding(4)
                Rectangle().fill(.purple).frame(height: 1)
                Rectangle()
                    .fill(.clear)
                    .frame(height: 400)
            }

            VStack(alignment: .leading, spacing: 0) {
                Rectangle().fill(.purple).frame(height: 1)
                Rectangle()
                    .fill(.clear)
                    .frame(height: 500)
            }
        }
        .font(.caption2)
        .fontWeight(.bold)
        .background(.thickMaterial)
        .frame(maxWidth: 300, maxHeight: 500)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .shadow(.cardLarge)
        .padding()

    }
    .ignoresSafeArea()
}
