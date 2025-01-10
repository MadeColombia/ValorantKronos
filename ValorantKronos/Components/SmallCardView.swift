//
//  SmallCardView.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/9/25.
//

import SwiftUI

struct SmallCardView: View {
    let title: String
    let image: String
    
    var body: some View {
        ZStack{
            VStack {
                Spacer()
                
                Text(title)
                    .font(.custom("Tungsten-Bold", size: 24))
                    .foregroundColor(.valorantRED)
                    .padding(.vertical)
            }.frame(width: 100, height: 210)
                .background(Color.deepRed)
                .clipShape(RoundedCorner(radius: 10, corners: .allCorners))
                .padding(10)
            
            ImageShape(imageName: image)
                .clipShape(RoundedCorner(radius: 10, corners: .allCorners))
                .overlay(
                    RoundedCorner(radius: 10, corners: .allCorners)
                        .stroke(.slightlyBlack, lineWidth: 2)
                )
                
        }
        .shadow(radius: 5)
    }
}

struct ImageShape: View {
    let imageName: String
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .clipShape(ChevronShape())
        }
        .frame(width: 100, height: 210)
    }
}

struct ChevronShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        /// Rectangle top
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))

        /// R Side
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        
        /// Chevron bottom
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY / 0.7))
        
        /// L Side
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    SmallCardView(title: "GAMEMODES", image: "SpikeImage")
}
