//
//  AppLaunchLoadingView.swift
//  ValorantKronos
//
//  Created by Pair Programming Assistant on 15/09/26.
//  Branded Valorant startup loading and preloading splash screen.
//

import SwiftUI

public struct AppLaunchLoadingView: View {
    @ObservedObject public var viewModel: AppLaunchViewModel
    
    public init(viewModel: AppLaunchViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            Color.slightlyBlack.ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                // Branded Logo
                VStack(spacing: 8) {
                    Image("ValorantLogo")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.valorantRED)
                    
                    Text("VALORANT")
                        .font(.custom(FontNames.tungstenBold, size: 48))
                        .foregroundColor(.almostWhite)
                    
                    Text("K R O N O S")
                        .font(.custom(FontNames.tungstenSemiBold, size: 20))
                        .foregroundColor(.valorantRED)
                        .tracking(6)
                }
                
                Spacer()
                
                // Status and Progress Area
                if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 36))
                            .foregroundColor(.valorantRED)
                        
                        Text(errorMessage)
                            .font(.custom(FontNames.tungstenMedium, size: 18))
                            .foregroundColor(.almostWhite)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button {
                            Task { await viewModel.startInitialization() }
                        } label: {
                            Text("RETRY CONNECTION")
                                .font(.custom(FontNames.tungstenBold, size: 22))
                                .foregroundColor(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color.valorantRED)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.bottom, 60)
                } else {
                    VStack(spacing: 14) {
                        Text(viewModel.statusMessage)
                            .font(.custom(FontNames.tungstenMedium, size: 18))
                            .foregroundColor(.almostWhite.opacity(0.85))
                            .tracking(1.5)
                        
                        // Custom Tactical Progress Bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.15))
                                    .frame(height: 6)
                                
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.valorantRED)
                                    .frame(width: max(geo.size.width * CGFloat(viewModel.progress), 12), height: 6)
                                    .animation(.easeInOut(duration: 0.35), value: viewModel.progress)
                            }
                        }
                        .frame(width: 260, height: 6)
                    }
                    .padding(.bottom, 60)
                }
            }
        }
    }
}

struct AppLaunchLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        AppLaunchLoadingView(viewModel: AppLaunchViewModel())
    }
}
