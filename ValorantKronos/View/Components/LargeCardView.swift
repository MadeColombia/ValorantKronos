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
    var body: some View {
        ZStack {
            Image("EventsImage") // Make sure to add the image to your assets
                .resizable()
                .scaledToFill()
            
            VStack {
                BlurView(style: .systemMaterialDark)
                    .opacity(0.7)
                    .frame(width: 121, height: 50)
                Spacer()
            }
            
            VStack {
                Text(self.title)
                    .foregroundColor(Color.almostWhite)
                    .font(.custom("Tungsten-SemiBold", size: 36))
                    .lineLimit(1)
                    .padding(10)
                Spacer()
            }.frame(width: 121)
                
        }
        .frame(width: 122, height: 291)
        .background(Color.almostWhite)
        .cornerRadius(10)
        .shadow(radius: 5)
        .rotationEffect(.degrees(isHorizontal ? 270 : 0))
    }
}

#Preview {
    LargeCardView(title: "PHANTOM CARINES", isHorizontal: false)
}
