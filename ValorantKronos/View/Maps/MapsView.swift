//
//  MapsView.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/11/25.
//

import SwiftUI

struct MapsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MapsViewModel()
    @State private var showPrincipalTitle = false
    
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

                    Text("MAPS")
                        .font(.custom(FontNames.tungstenBold, size: 64))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(showPrincipalTitle ? 0 : 1)
                    
                    CardCarrousel(maps: viewModel.maps)
                        .padding(.vertical, 30)
                }
            }
            .scrollIndicators(.automatic)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadMaps()
        }
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
                Text("MAPS")
                    .font(.custom(FontNames.tungstenSemiBold, size: 25))
                    .opacity(showPrincipalTitle ? 1 : 0)
                    .animation(.easeOut(duration: 0.2), value: showPrincipalTitle)
            }
        }
    }
}

struct CardCarrousel: View {
    let maps: [Map]
    @State private var selectedMap: Map?
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(maps) { map in
                if let splashImage = map.splash {
                Button(action: { selectedMap = map }) {
                        LargeCardView(title: map.displayName, portraitImage: splashImage, isHorizontal: true)
                    }
                }
            }
        }
        .sheet(item: $selectedMap) { map in
            NavigationView {
                SingleMapView(map: map)
                    .interactiveDismissDisabled()
            }
        }
    }
}
        
#Preview {
    NavigationView {
        MapsView()
    }
}
