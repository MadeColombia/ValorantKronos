//
//  SingleAgentView.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/11/25.
//

import SwiftUI

struct SingleAgentView: View {
    @Environment(\.dismiss) private var dismiss
    let selectedAgent: Agent

    var body: some View {
            ZStack {
                Color.slightlyBlack
                    .ignoresSafeArea()

                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        VStack(spacing: 0) {
                            CachedAsyncImage(url: URL(string: self.selectedAgent.fullPortrait ?? "")) { phase in
                                switch phase {
                                case .success(let image):
                                    ZStack{
                                        Image("AgentBackgroundDark")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)

                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .containerRelativeFrame(.vertical) { height, _ in height / 2 }
                                            .background(
                                                CachedAsyncImage(url: URL(string: self.selectedAgent.background ?? "")) { phase in
                                                    if let image = phase.image {
                                                        image.resizable().aspectRatio(contentMode: .fill)
                                                    } else {
                                                        Color.clear
                                                    }
                                                }
                                                .opacity(0.05)
                                            )
                                    }
                                case .failure, .empty:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .foregroundStyle(Color.almostWhite)
                                        .frame(width: 15, height: 15)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.7)
                            .clipped()

                            VStack(spacing: 0){
                                AgentInfo(selectedAgent: self.selectedAgent)
                            }
                        }
                    }
                    .ignoresSafeArea(edges: .top)
                    .scrollIndicators(.hidden)
                    .toolbarBackground(.hidden)
                }
            }.navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.backward")
                            Text("AGENTS")
                                .font(.custom(FontNames.tungstenMedium, size: 22))
                        }
                        .foregroundStyle(.white)
                    }
                }
            }
    }
}

struct AgentInfo: View {
    @State private var showDeveloperName = false
    let selectedAgent: Agent


    var body: some View {
        VStack (spacing: 0){
            HStack {
                VStack(alignment: .leading) {
                    if showDeveloperName {
                        Text(self.selectedAgent.developerName)
                            .foregroundColor(Color.valorantRED)
                            .font(.custom("Tungsten-Bold", size: 80))
                            .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .move(edge: .top).combined(with: .opacity)))
                    } else {
                        Text(self.selectedAgent.displayName)
                            .foregroundColor(Color.almostWhite)
                            .font(.custom("Tungsten-Bold", size: 80))
                            .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .move(edge: .top).combined(with: .opacity)))
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        showDeveloperName.toggle()
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)

            AgentTypeBadge(role: self.selectedAgent.role)

            Text(self.selectedAgent.description)
                .lineLimit(5)
                .font(.custom("Tungsten-Light", size: 20))
                .foregroundColor(Color.almostWhite)
                .padding()

            Spacer()

            SpecialAbilitiesView(abilities: self.selectedAgent.abilities)
                .padding(.top, 50)
        }
    }
}

struct AgentTypeBadge: View {
    let role: Role?

    var body: some View {
        HStack {
            HStack(alignment: .center,spacing: 15) {
                Text(self.role?.displayName ?? "Undefined")
                    .textCase(.uppercase)
                    .font(.custom("Tungsten-Semibold", size: 20))
                    .foregroundColor(Color.almostWhite)

                CachedAsyncImage(url: URL(string: self.role?.displayIcon ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(Color.valorantRED)
                            .frame(width: 20, height: 20)
                    case .failure, .empty:
                        Image(systemName: "photo")
                            .resizable()
                            .foregroundStyle(Color.almostWhite)
                            .frame(width: 20, height: 20)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 35)
            .background(Color.valorantBlack)
            .clipShape(RoundedCorner(radius: 10))

            Spacer()
        }.padding(.horizontal)

    }

}

struct SpecialAbilitiesView: View {
    let abilities: [Ability]

    var body: some View {
        VStack(spacing: 30) {
            Text("SPECIAL ABILITIES")
                .font(.custom("Tungsten-Semibold", size: 36))
                .foregroundColor(Color.almostWhite)
                .padding(.horizontal)

            VStack(spacing: 20) {
                ForEach(self.abilities) { ability in
                    if ability.displayIcon != nil && ability.displayIcon != "" {
                        AbilityCardView(ability: ability)
                            .padding(.horizontal)
                    }
                }

            }
        }
    }
}

struct AbilityCardView: View {
    let ability: Ability

    var body: some View {
        HStack {
            CachedAsyncImage(url: URL(string: self.ability.displayIcon ?? ""), content: { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(5)
                case .failure, .empty:
                    ProgressView()
                        .frame(width: 50, height: 50)
                @unknown default:
                    EmptyView()
                }
            })

            VStack(alignment: .leading) {
                Text(self.ability.displayName)
                    .font(.custom("Tungsten-Semibold", size: 20))
                    .foregroundColor(Color.almostWhite)
                    .padding(.horizontal)
                Text(self.ability.description)
                    .font(.custom("Tungsten-Light", size: 16))
                    .foregroundColor(Color.almostWhite)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.valorantBlack)
        .clipShape(RoundedCorner(radius: 10, corners: .allCorners))
        .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(self.ability.slot == "Ultimate" ? Color.valorantRED : Color.valorantBlack, lineWidth: 2)
            )
    }
}

#Preview {
    NavigationView(content: {
        SingleAgentView(selectedAgent: mockAgent)
    })

}
