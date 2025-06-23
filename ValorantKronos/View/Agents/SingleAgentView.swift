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
                            AsyncImage(url: URL(string: self.selectedAgent.fullPortrait ?? "")) { image in
                                ZStack{
                                    Image("AgentBackgroundDark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .containerRelativeFrame(.vertical) { height, _ in height / 2 }
                                        .background( AsyncImage(url: URL(string: self.selectedAgent.background ?? "")).opacity(0.05))
                                }
                                
                            } placeholder: {
                                Image(systemName: "photo")
                                    .resizable()
                                    .foregroundStyle(Color.almostWhite)
                                    .frame(width: 15, height: 15)
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
    let selectedAgent: Agent

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Text("04")
                        .foregroundStyle(Color.gray)
                        .opacity(0.03)
                        .font(.custom("Tungsten-Semibold", size: 350))
                        .rotationEffect(Angle(degrees: 270))
                        .offset(x:15 ,y: -40)
                }
                Spacer()
            }
            
            
            VStack (spacing: 0){
                HStack {
                    Text(self.selectedAgent.displayName)
                        .foregroundColor(Color.almostWhite)
                        .font(.custom("Tungsten-Bold", size: 80))
                        .padding(.horizontal)
                    Spacer()
                }.padding(.top)
                
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
                
                AsyncImage(url: URL(string: self.role?.displayIcon ?? "")) { image in
                        image
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(Color.valorantRED)
                            .frame(width: 20, height: 20)
                    
                } placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .foregroundStyle(Color.almostWhite)
                        .frame(width: 20, height: 20)
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
        VStack(spacing: 20) {
            Text("SPECIAL ABILITIES")
                .font(.custom("Tungsten-Semibold", size: 36))
                .foregroundColor(Color.almostWhite)
                .padding(.horizontal)
            
            VStack {
                ForEach(self.abilities) { ability in
                    if ability.displayIcon != nil && ability.displayIcon != "" {
                        
                        AbilityCardView(slot: ability.slot, image: ability.displayIcon!, name: ability.displayName, description: ability.description)
                            .padding()
                    }
                }
                
            }
        }
    }
}

struct AbilityCardView: View {
    let slot: String
    let image: String
    let name: String
    let description: String
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: self.image), content: {image in
                image
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding(5)
            }, placeholder: {
                Text("wait")
            })
            
            VStack(alignment: .leading) {
                Text(self.name)
                    .font(.custom("Tungsten-Semibold", size: 20))
                    .foregroundColor(Color.almostWhite)
                    .padding(.horizontal)
                Text(self.description)
                    .font(.custom("Tungsten-Light", size: 16))
                    .foregroundColor(Color.almostWhite)
                    .padding(.horizontal)
            }
        }
        .padding()
        .background( Color.valorantBlack)
        .clipShape(RoundedCorner(radius: 10, corners: .allCorners))
        .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(self.slot == "Ultimate" ? Color.valorantRED : Color.valorantBlack, lineWidth: 2)
            )
        
        
    }
}

#Preview {
    NavigationView(content: {
        SingleAgentView(selectedAgent: mockAgent)
    })
    
}
