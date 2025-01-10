//
//  MainView.swift
//  ValorantKronos
//
//  Created by Ethan Montalvo on 3/01/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        ZStack {
            Color.slightlyBlack
                .ignoresSafeArea()

            GeometryReader { geometry in
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        Valorant1stBlock()
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.9)
                        Valorant2ndBlock()
                            .frame(width: geometry.size.width, height: 350)
                        Valorant3rdBlock()
                            .frame(width: geometry.size.width, height: 400)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}


struct Valorant1stBlock: View {
    var body: some View {
        VStack {
            Spacer()
            ValorantTypograph()
            Spacer()
        }.background(Image("BackgroundMainView")
            .resizable()
            .scaledToFill()
            .opacity(0.5))
    }
}

struct ValorantTypograph: View {
    var body: some View {
        VStack{
            Text("WE ARE")
                .font(.custom("Tungsten-Semibold", size: 32))
                .foregroundStyle(Color(red: 255, green: 248, blue: 248))
            Image("KronosTypograph")
                .padding(.bottom, 10)
                .padding(.top, -15)
            Text("THE PLACE TO FIND EVERYTHING ABOUT THE 5V5 GAME")
                .font(.custom("Tungsten-Semibold", size: 16))
                .foregroundStyle(Color(red: 255, green: 248, blue: 248))
        }
    }
}

struct Valorant2ndBlock: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            Text("MAIN CATEGORIES")
                .font(.custom("Tungsten-Bold", size: 64))
                .foregroundStyle(.white)
                .padding(.leading)
            ScrollView(.horizontal) {
                LazyHStack(alignment: .center,spacing: 30) {
                    MenuCardView(imageName: "AgentsImage", title: "AGENTS")
                    MenuCardView(imageName: "WeaponsImage", title: "WEAPONS")
                    MenuCardView(imageName: "MapsImage", title: "MAPS")
                }
                .padding(.horizontal, 20)
                .scrollTargetLayout()
            }
            .frame(height: 230)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Image("PlainRedBg")
            .resizable())
    }
}

struct Valorant3rdBlock: View {
    var body: some View {
        VStack{
            Spacer()
            Text("ABOUT THE GAME")
                .font(.custom("Tungsten-Semibold", size: 48))
                .foregroundStyle(.slightlyBlack)
            HStack(spacing: 2){
                SmallCardView(title: "EVENTS", image: "EventsImage")
                SmallCardView(title: "GAMEMODES", image: "SpikeImage")
                SmallCardView(title: "SEASONS", image: "SeasonsImage")
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Image("TextBgWhite")
            .resizable())
    }
}

#Preview {
    MainView()
}
