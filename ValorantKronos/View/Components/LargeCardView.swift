//
//  LargeCardView.swift
//  ValorantKronos
//
//  Created by Ethan Montalvo on 31/03/25.
//

import SwiftUI

struct LargeCardView: View {
    let title: String
    let isHorizontal: Bool

    private let cardWidth: CGFloat = 140
    private let cardHeight: CGFloat = 340

    var body: some View {
        LargeCardStructure(title: title)
            .rotationEffect(.degrees(isHorizontal ? 270 : 0))
            .frame(width: isHorizontal ? cardHeight : cardWidth, height: isHorizontal ? cardWidth : cardHeight)
    }
}
struct LargeCardStructure: View {
    let title: String
    
    var body: some View {
        ZStack {
            Image("EventsImage") // Make sure to add the image to your assets
                .resizable()
                .scaledToFill()
            
            VStack {
                BlurView(style: .systemMaterialDark)
                    .opacity(0.7)
                    .frame(width: 140, height: 50)
                Spacer()
            }
            
            VStack {
                Text(title)
                    .foregroundColor(.almostWhite)
                    .font(.custom("Tungsten-SemiBold", size: 36))
                    .lineLimit(1)
                    .padding(10)
                Spacer()
            }.frame(width: 140)
                
        }
        .frame(width: 140, height: 340)
        .background(Color.almostWhite)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview {
    LargeCardView(title: "PHANTOM CARINES", isHorizontal: false)
}
