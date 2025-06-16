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
    @State private var isExpanded: Bool = false
    
    private var threeColumnGrid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    // Custom colors for the overlay for better readability
    private let overlayLightBorderColor = Color(red: 236/255, green: 234/255, blue: 235/255)
    private let overlayDarkShadowColor = Color(red: 192/255, green: 189/255, blue: 191/255)
    private let overlayLightShadowColor = Color.white
    
    var body: some View {
        ZStack {
            Color.almostWhite // Assuming Color.almostWhite is defined
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
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
                        .padding(.vertical)
                        .background(Color.almostWhite) // Background for the dropdown content area
                        .overlay(
                            RoundedRectangle(cornerRadius: 15) // Apply stroke and shadows to a RoundedRectangle
                                .stroke(overlayLightBorderColor, lineWidth: 4)
                                .shadow(color: overlayDarkShadowColor, radius: 3, x: 5, y: 5)
                                .shadow(color: overlayLightShadowColor, radius: 2, x: -2, y: -2)
                                // Note: The original overlay had a more complex shadow/clipping sequence.
                                // This simplified overlay provides a similar neomorphic feel.
                                // If the exact original shadow effect is crucial, the previous structure was more specific.
                        )
                        // .ignoresSafeArea() // Consider if the overlay itself should ignore safe areas
                        
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
                    }
                    .tint(.clear) // Removes default disclosure group arrow
                    
                    Spacer()
                }
                .padding()
                
                ScrollView {
                    LazyVGrid(columns: threeColumnGrid, spacing: 0) {
                        // Placeholder data - replace with actual agent data
                        // For performance with images in AgentCardView:
                        // 1. Use AsyncImage for network images.
                        // 2. Ensure images are appropriately sized.
                        ForEach(0 ..< 20) { number in // Should iterate over actual agent data
                            NavigationLink(destination: {
                                // Ensure mockAgent or actual agent data is passed
                                SingleAgentView(selectedAgent: mockAgent)
                            }, label: {
                                AgentCardView(agentNumber: number, agent: mockAgent)
                                    .shadow(radius: 10) // Be mindful of shadow performance on complex views
                            })
                        }
                    }
                    .padding(.horizontal, 10)
                }
                .scrollIndicators(.hidden)
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
    AgentsView()
}
