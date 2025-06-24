//
//  AgentsView.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/11/25.
//

import SwiftUI

struct AgentsView: View {
    @Environment(\.dismiss) private var dismiss
    @State var selection1: String = "ALL AGENTS"
    var agentTypes = ["ALL AGENTS", "CONTROLLERS", "DUELISTS", "INITIATORS", "SENTINELS"]
    @State private var isExpanded: Bool = false
    @State private var showPrincipalTitle = false
    
    private var threeColumnGrid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    // Custom colors for the overlay for better readability
    private let overlayLightBorderColor = Color(red: 236/255, green: 234/255, blue: 235/255)
    private let overlayDarkShadowColor = Color(red: 192/255, green: 189/255, blue: 191/255)
    private let overlayLightShadowColor = Color.white
    
    var body: some View {
        ZStack {
            Color.almostWhite.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // This GeometryReader tracks the scroll position to fade the title.
                    GeometryReader { geo in
                        let scrollOffset = geo.frame(in: .global).minY
                        Color.clear
                            .onChange(of: scrollOffset) { _, newOffset in
                                showPrincipalTitle = newOffset <= 40
                            }
                    }
                    .hidden()

                    VStack(alignment: .leading, spacing: 0) {
                            DisclosureGroup(isExpanded: $isExpanded) {
                                // Dropdown content
                                VStack(spacing: 5) {
                                    ForEach(agentTypes, id: \.self) { option in
                                        HStack {
                                            Text(option)
                                            Spacer()
                                            Image(systemName: "checkmark")
                                                .opacity(selection1 == option ? 1 : 0)
                                        }
                                        .foregroundStyle(selection1 == option ? Color.primary : Color.gray)
                                        .animation(.none, value: selection1) // Prevent animation on selection change for individual items
                                        .contentShape(Rectangle()) // Ensures the whole HStack is tappable
                                        .padding(.horizontal, 10)
                                        .onTapGesture {
                                            withAnimation(.snappy) { // Use snappy animation for selection and closing
                                                selection1 = option
                                                isExpanded.toggle()
                                            }
                                        }
                                    }
                                }
                                .padding(15)
                                .background(Color.almostWhite)// Background for the dropdown content area
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20) // Apply stroke and shadows to a RoundedRectangle
                                        .stroke(overlayLightBorderColor, lineWidth: 5)
                                        .shadow(color: overlayDarkShadowColor, radius: 4, x: 5, y: 5)
                                        .shadow(color: overlayLightShadowColor, radius: 4, x: -2, y: -2)
                                        .clipShape(RoundedRectangle(cornerRadius: 20)) // Clip to rounded rectangle shape
                                )
                                
                                
                            } label: {
                                // DisclosureGroup Label
                                HStack {
                                    Text(selection1)
                                        .foregroundColor(Color.slightlyBlack) // Assuming Color.slightlyBlack is defined
                                        .font(.custom("Tungsten-Bold", size: 64))
                                        .lineLimit(1)
                                    Image(systemName: "arrowtriangle.up.fill") // Use a consistent arrow icon
                                        .foregroundColor(Color.black)
                                        .imageScale(.large)
                                        .rotationEffect(.degrees(isExpanded ? 180 : 0)) // Rotate arrow based on isExpanded
                                }
                                .animation(.easeInOut(duration: 0.2), value: isExpanded) // Animate arrow rotation
                                .opacity(showPrincipalTitle ? 0 : 1)
                            }
                            .tint(.clear)
                            .padding(.horizontal)
                        
                        ScrollView {
                            LazyVGrid(columns: threeColumnGrid, spacing: 0) {
                                ForEach(0 ..< 20) { number in
                                    NavigationLink(destination: {
                                        SingleAgentView(selectedAgent: mockAgent)
                                    }, label: {
                                        AgentCardView(agentNumber: number, agent: mockAgent)
                                    })
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.backward")
                            Text("BACK")
                                .font(.custom(FontNames.tungstenMedium, size: 22))
                        }
                        .foregroundStyle(.slightlyBlack)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(self.selection1)
                        .font(.custom(FontNames.tungstenSemiBold, size: 25))
                        .opacity(showPrincipalTitle ? 1 : 0)
                        .animation(.easeOut(duration: 0.2), value: showPrincipalTitle)
                }
            }
    }
}

// MARK: - Placeholder Data and Views (for context)
// These should be properly defined in your project.
//
//struct AgentCardView: View { // Minimal example
//    let agentNumber: Int // Or actual agent data
//    let agent: Agent
//    var body: some View {
//        VStack {
//            // If agent.displayIcon is a URL, use AsyncImage here:
//            // AsyncImage(url: URL(string: agent.displayIcon)) { image in image.resizable() } placeholder: { ProgressView() }
//            Image(systemName: agent.displayIcon) // Placeholder if local
//                .resizable()
//                .scaledToFit()
//                .frame(width: 80, height: 80)
//                .padding()
//            Text(agent.name)
//        }
//        .frame(maxWidth: .infinity, minHeight: 150)
//        .background(Color.gray.opacity(0.2))
//        .cornerRadius(10)
//        .padding(5)
//    }
//}

#Preview {
    NavigationView(content: {
        AgentsView()
    })
}
