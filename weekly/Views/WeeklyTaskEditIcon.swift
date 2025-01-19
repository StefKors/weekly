//
//  WeeklyTaskEditIcon.swift
//  weekly
//
//  Created by Stef Kors on 17/01/2025.
//

import SwiftUI
import SwiftData

struct WeeklyTaskEditIconItem: View {
    let task: WeeklyTask
    let option: IconOptions
    
    @Binding var isActive: Bool
    var isSelected: Bool
    var size: CGFloat
    
    @State private var isHovering: Bool = false
    
    var body: some View {
        Button  {
            if isActive {
                withAnimation(.snappy(duration: 0.2)) {
                    task.icon = option.rawValue
                    isActive = false
                }
            } else {
                withAnimation(.snappy(duration: 0.2)) {
                    isActive.toggle()
                }
            }
        } label : {
            Image(option.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .opacity(option.rawValue == task.icon || isHovering ? 1 : 0.4)
                .onHover { hoverState in
                    withAnimation(.snappy(duration: 0.2)) {
                        isHovering = hoverState
                    }
                }
        }
        .buttonStyle(.plain)
        .containerShape(shape)
        .opacity(isSelected ? 1 : 0)
    }
    
    var shape: some InsettableShape {
        RoundedRectangle(cornerRadius: 4)
    }
}

struct WeeklyTaskEditIcon: View {
    @Bindable var task: WeeklyTask
    
    @Environment(\.entry) private var entry
    
    @State var isActive: Bool = false
    
    private let size: CGFloat = 20
    
    private let spacing: CGFloat = 2
    
    var body: some View {
        shape
            .fill(.clear)
            .frame(width: size + 4, height: size + 4, alignment: .leading)
            .overlay(alignment: .leading) {
                HStack(spacing: isActive ? 2 : -size) {
                    ForEach(IconOptions.allCases, id: \.self) { option in
                        WeeklyTaskEditIconItem(
                            task: task,
                            option: option,
                            isActive: $isActive,
                            isSelected: isActive || option.rawValue == task.icon,
                            size: size
                        )
                    }
                }
                .padding(2)
                .containerShape(shape)
                .background {
                    shape.fill(.background)
                        .shadow(.cardLarge)
                        .opacity(isActive ? 1 : 0)
                }
                
            }
    }
    
    var shape: some InsettableShape {
        RoundedRectangle(cornerRadius: 4)
    }
}

#Preview {
    WeeklyTaskEditIcon(task: .preview)
        .scenePadding()
}
