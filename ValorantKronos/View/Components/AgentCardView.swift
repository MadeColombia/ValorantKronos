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
            BackgroundAgentImage(agentFullPortraitURLString: agent.fullPortrait ?? "")
            
            VStack {
                HStack {
                    Text("\(agentNumber > 9 ? "" : "0" )\(agentNumber).")
                        .font(.custom("Tungsten-Bold", size: 20))
                        .foregroundStyle(Color.white)
                        
                    Spacer()
                    
                    Image("ValorantLogo") // Ensure this is a template image or SF Symbol if .foregroundStyle is intended to work
                        .resizable()
                        .foregroundStyle(Color.white)
                        .frame(width: 30, height: 30)
                }
                .padding(.horizontal, 8)
                .padding(.top, 5)
                
                Spacer()
                
                VStack(spacing: 1) {
                    Text(agent.displayName)
                        .font(.custom("Tungsten-Bold", size: 40))
                        .foregroundStyle(Color.white)
                    
                    AsyncImage(url: URL(string: agent.role?.displayIcon ?? "")) { image in
                            image
                                .renderingMode(.template) // Necessary for .foregroundStyle to apply color
                                .resizable()
                                .foregroundStyle(Color.valorantRED)
                                .frame(width: 15, height: 15)
                        
                    } placeholder: {
                        Image(systemName: "photo") // Default placeholder
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.almostWhite)
                            .frame(width: 15, height: 15)
                    }
                }
                .padding(5)
            }
            .frame(width: 121, height: 150)
        }
    }
}

struct BackgroundAgentImage: View {
    let agentFullPortraitURLString: String

    var body: some View {
        AsyncImage(url: URL(string: agentFullPortraitURLString)) { loadedImage in
            // This ZStack's content is what's displayed when the image is loaded.
            // It's framed to 121x150 and then clipped by the outer .clipShape(ShieldShape()).
            ZStack {
                Image("MapsImage")
                    .resizable()
                    .opacity(0.6) // Opacity applied to MapsImage
                    .background(Color.valorantBlack) // Background for the MapsImage view
                    .clipShape(ShieldShape()) // Clipped as per original
                    .frame(width: 121, height: 150) // Framed as per original
                    .scaledToFill() // Scaled as per original

                loadedImage
                    .resizable()
                    .frame(width: 220, height: 220) // Agent image conceptual frame
                    .offset(y: 20) // Offset as per original
                    .clipShape(ShieldShape()) // Clipped as per original
                    .frame(width: 121, height: 150) // Framed as per original

                BlurView(style: .systemMaterialDark)
                    .opacity(0.7)
                    .frame(width: 121, height: 80) // Framed as per original
                    .offset(y: 50) // Offset as per original

                ShieldShape() // The shape for the stroke
                    .stroke(Color.valorantBlack, lineWidth: 4.0)
                    .frame(width: 121, height: 150) // Stroke layer framed as per original
            }
            // The ZStack itself isn't explicitly framed here, its size is determined by its content,
            // which includes layers framed to 121x150.
        } placeholder: {
            // Placeholder content, also 121x150, to be clipped by ShieldShape.
            ZStack {
                Image("MapsImage")
                    .resizable()
                    .opacity(0.6)
                    .background(Color.valorantBlack)
                    .clipShape(ShieldShape())
                    .frame(width: 121, height: 150)
                    .scaledToFill()
                ProgressView().tint(Color.white) // Simple progress indicator
            }
        }
        // Modifiers applied to the AsyncImage view itself:
        .background(Color.valorantBlack) // Fallback background for the AsyncImage container
        .clipShape(ShieldShape()) // Master clip for whatever AsyncImage resolves to
        .padding() // Outermost padding, applied *after* clipping.
    }
}

struct ShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let cornerRadius: CGFloat = 20
        
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        path.addArc(
            center: CGPoint(x: width - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: -90),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        path.addArc(
            center: CGPoint(x: width - 20 , y: height - 40),
            radius: 20,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 60 ),
            clockwise: false
        )
        path.addArc(
            center: CGPoint(x: rect.midX , y: height - 30),
            radius: 30,
            startAngle: Angle(degrees: 60),
            endAngle: Angle(degrees: 120),
            clockwise: false
        )
        path.addArc(
            center: CGPoint(x: cornerRadius , y: height - 40),
            radius: 20,
            startAngle: Angle(degrees: 120),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
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
    let style: UIBlurEffect.Style
    
    init(style: UIBlurEffect.Style) {
        self.style = style
    }
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        return blurView
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// Assuming mockAgent is defined for Preview
// struct Agent { /* ... properties like fullPortrait, displayName, role etc. ... */ }
// let mockAgent = Agent(...)

#Preview {
    AgentCardView(agentNumber: 1, agent: mockAgent)
}
