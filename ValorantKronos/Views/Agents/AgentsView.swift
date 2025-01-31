//
//  AgentsView.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/11/25.
//

import SwiftUI

struct AgentsView: View {
    @State var selection1: String = "ALL AGENTS"
    var agentTypes = ["ALL AGENTS", "CONTROLLERS", "DUELISTS", "INITIATORS", "SENTINELS"]
    
    private var threeColumnGrid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        
        NavigationView(content: {
            ZStack {
                Color.almostWhite
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0){
                    HStack{
                        DropDownPicker( selection: $selection1, options: agentTypes)
                            .padding()
                        Spacer()
                    }.frame(height: 90)
                    .zIndex(1)
                    
                    ScrollView {
                        LazyVGrid(columns: threeColumnGrid, spacing: 0) {
                            ForEach(0 ..< 20) { Number in
                                NavigationLink(destination: {SingleAgentView(selectedAgent: mockAgent)}, label: {
                                    AgentCardView(agentNumber: Number, agent: mockAgent)
                                        .shadow(radius: 10)
                                })
                            }
                        }.padding(.horizontal, 10)
                    }.scrollIndicators(.hidden)
                }
            }
        })
    }
}

#Preview {
    AgentsView()
}
