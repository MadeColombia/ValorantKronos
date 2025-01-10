//
//  MenuCardView.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/9/25.
//

import SwiftUI

struct MenuCardView: View {
    let imageName: String
    let title: String
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Rectangle()
                    .fill(Color.valorantRED)
                    .frame(height: 30) // Adjust height
                
                Text(title)
                    .font(.custom("Tungsten-Bold", size: 96))
                    .foregroundStyle(.white)
                    
            }
            
        }.background(Image(imageName)
            .resizable()
            .scaledToFill())
        .frame(width: 300, height: 200)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview {
    MenuCardView(imageName: "AgentsImage", title: "AGENTS")
}
