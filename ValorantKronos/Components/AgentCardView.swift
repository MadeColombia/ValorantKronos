//
//  AgentCardView.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/6/25.
//

import SwiftUI


struct AgentCardView: View {
    let agentNumber: Int
    let agent: Agent
    
    var body: some View {
            ZStack {
                BackgroundAgentImage(image: self.agent.fullPortrait ?? "")
                
                VStack {
                    HStack {
                        Text("\(self.agentNumber > 9 ? "" : "0" )\(self.agentNumber).")
                            .font(.custom("Tungsten-Bold", size: 20))
                            .foregroundStyle(Color.white)
                            
                        Spacer()
                        
                        Image("ValorantLogo")
                            .resizable()
                            .foregroundStyle(Color.white)
                            .frame(width: 30, height: 30)
                    }.padding(.horizontal,8)
                        .padding(.top, 5)
                    
                    Spacer()
                    
                    VStack(spacing: 1) {
                        Text(self.agent.displayName)
                            .font(.custom("Tungsten-Bold", size: 40))
                            .foregroundStyle(Color.white)
                        
                        AsyncImage(url: URL(string: agent.role?.displayIcon ?? "")) { image in
                                image
                                    .renderingMode(.template)
                                    .resizable()
                                    .foregroundStyle(Color.valorantRED)
                                    .frame(width: 15, height: 15)
                            
                        } placeholder: {
                            Image(systemName: "photo")
                                .resizable()
                                .foregroundStyle(Color.almostWhite)
                                .frame(width: 15, height: 15)
                        }
                    }.padding(5)
                }.frame(width: 121, height: 150)
            }
    }
}

struct BackgroundAgentImage: View {
    var image: String
    var body: some View {
        AsyncImage(url: URL(string: self.image)) { image in
            ZStack{
                Image("MapsImage")
                    .resizable()
                    .opacity(0.6)
                    .background(Color.valorantBlack)
                    .clipShape(ShieldShape())
                    .frame(width: 121, height: 150)
                    .scaledToFill()
                
                image
                    .resizable()
                    .frame(width: 220, height: 220)
                    .offset(y: 20)
                    .clipShape(ShieldShape())
                    .frame(width: 121, height: 150)
                
                BlurView(style: .systemMaterialDark)
                    .opacity(0.7)
                    .frame(width: 121, height: 80)
                    .offset(y: 50)
                
                ShieldShape()
                    .stroke(Color.valorantBlack, lineWidth: 4.0)
                    .frame(width: 121, height: 150)

            }
            
        } placeholder: {
            Image(systemName: "photo")
                .resizable()
                .frame(width: 15, height: 15)
                .foregroundStyle(Color.slightlyBlack)
                
        }
        .clipShape(ShieldShape())
        .padding()
       
    }
}

struct ShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Calculate dimensions
        let width = rect.width
        let height = rect.height
        let cornerRadius: CGFloat = 20
        
        // Start from top left
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        
        // Top edge
        path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        
        // Top right corner
        path.addArc(
            center: CGPoint(x: width - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: -90),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        
        // Right edge
        path.addArc(
            center: CGPoint(x: width - 20 , y: height - 40),
            radius: 20,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 60 ),
            clockwise: false
        )
        
        // Bottom point
        path.addArc(
            center: CGPoint(x: rect.midX , y: height - 30),
            radius: 30,
            startAngle: Angle(degrees: 60),
            endAngle: Angle(degrees: 120),
            clockwise: false
        )
        
        // Bottom left corner
        path.addArc(
            center: CGPoint(x: cornerRadius , y: height - 40),
            radius: 20,
            startAngle: Angle(degrees: 120),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )
        
        // Left edge
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        
        // Top left corner
        path.addArc(
            center: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        
        return path
    }
}

struct ShieldTitleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Calculate dimensions
        let width = rect.width
        let height = rect.height
        let cornerRadius: CGFloat = 20
        
        // Start from top left
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        
        // Top edge
        path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        
        // Top right corner
        path.addArc(
            center: CGPoint(x: width - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: -90),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        
        // Right edge
        path.addArc(
            center: CGPoint(x: width - 20 , y: height - 40),
            radius: 20,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 60 ),
            clockwise: false
        )
        
        // Bottom point
        path.addArc(
            center: CGPoint(x: rect.midX , y: height - 30),
            radius: 30,
            startAngle: Angle(degrees: 60),
            endAngle: Angle(degrees: 120),
            clockwise: false
        )
        
        // Bottom left corner
        path.addArc(
            center: CGPoint(x: cornerRadius , y: height - 40),
            radius: 20,
            startAngle: Angle(degrees: 120),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )
        
        // Left edge
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        
        // Top left corner
        path.addArc(
            center: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        
        return path
    }
}

struct BlurView: UIViewRepresentable {
    
    // Declare a property 'style' of type UIBlurEffect.Style to store the blur effect style.
    let style: UIBlurEffect.Style
    
    // Initializer for the BlurView, taking a UIBlurEffect.Style as a parameter and setting it to the 'style' property.
    init(style: UIBlurEffect.Style) {
        self.style = style
    }
    
    // Required method of UIViewRepresentable protocol. It creates and returns the UIVisualEffectView.
    func makeUIView(context: Context) -> UIVisualEffectView {
        // Create a UIBlurEffect with the specified 'style'.
        let blurEffect = UIBlurEffect(style: style)
        // Initialize a UIVisualEffectView with the blurEffect.
        let blurView = UIVisualEffectView(effect: blurEffect)
        // Return the configured blurView.
        return blurView
    }
    
    // Required method of UIViewRepresentable protocol. Here, it's empty as we don't need to update the view after creation.
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    AgentCardView(agentNumber: 1, agent: mockAgent)
}
