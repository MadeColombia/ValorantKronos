//
//  DropDownPicker.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/12/25.
//

import SwiftUI

enum DropDownPickerState {
    case top
    case bottom
}

struct DropDownPicker: View {
    
    @Binding var selection: String
    var state: DropDownPickerState = .bottom
    var options: [String]
    var maxWidth: CGFloat = 180
    
    @State var showDropdown = false
    
    @SceneStorage("drop_down_zindex") private var index = 1000.0
    @State var zindex = 1000.0
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack(alignment: .leading,spacing: 0) {
                HStack {
                    Text(selection)
                        .foregroundColor(Color.slightlyBlack)
                        .font(.custom("Tungsten-Bold", size: 64))
                        .lineLimit(1)
                    
                    Spacer(minLength: 10)
                    
                    Image(systemName: state == .top ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees((showDropdown ? -180 : 02)))
                }
                .fixedSize(horizontal: true, vertical: false)
                .background(Color.almostWhite)
                .onTapGesture {
                    index += 1
                    zindex = index
                    withAnimation(.snappy) {
                        showDropdown.toggle()
                    }
                }
                .zIndex(10)
                
                if state == .bottom && showDropdown {
                    OptionsView()
                }
            }
            .clipped()
            .background(Color.almostWhite)
            .frame(height: size.height, alignment: state == .top ? .bottom : .top)
            
        }
        .frame(width: maxWidth)
        .zIndex(zindex)
    }
    
    
    func OptionsView() -> some View {
        VStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                HStack {
                    Text(option)
                    Spacer()
                    Image(systemName: "checkmark")
                        .opacity(selection == option ? 1 : 0)
                }
                .foregroundStyle(selection == option ? Color.primary : Color.gray)
                .animation(.none, value: selection)
                .frame(height: 30)
                .frame(width: maxWidth)
                .contentShape(.rect)
                .padding(.horizontal, 10)
                .onTapGesture {
                    withAnimation(.snappy) {
                        selection = option
                        showDropdown.toggle()
                    }
                }
            }
        }
        .transition(.move(edge: state == .top ? .bottom : .top))
        .zIndex(1)
    }
}

#Preview {
    AgentsView()
}
