//
//  SingleMapView.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/11/25.
//

import SwiftUI

struct SingleMapView: View {
    @Environment(\.dismiss) var dismiss
    var map: Map
    @State private var imageSelection = 0
    @State private var isExpanded: Bool = false
    
    private var mapImages: [URL] {
        [
            map.splash,
            map.listViewIconTall
        ]
        .compactMap { $0 }
        .compactMap { URL(string: $0) }
    }

    var body: some View {
        ZStack {
            Color.deepRed
                .ignoresSafeArea()
        
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        ZStack(alignment: .bottomLeading) {
                            ImageCarouselView(selection: $imageSelection, mapImages: mapImages)
                                .frame(width: geometry.size.width, height: geometry.size.height * 0.9)
                                .clipped()

                            MapInfo(map: map, pageCount: mapImages.count, currentPage: $imageSelection)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.clear, Color.slightlyBlack.opacity(0.9) ,Color.valorantBlack]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                        
                        DisclosureGroup(isExpanded: $isExpanded, content: {
                            MiniMapView(
                                miniMap: map.displayIcon,
                                bgImage: map.premierBackgroundImage
                            )
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
                        }, label: {
                            Spacer()
                            HStack(spacing: 0) {
                                Text("MINI MAP")
                                    .font(.custom("Tungsten-SemiBold", size: 30))
                                    .foregroundStyle(isExpanded ? Color.valorantRED : Color.disabled)
                                    .padding(10)
                                Image(systemName: "arrowtriangle.up.fill")
                                    .foregroundColor(isExpanded ? Color.valorantRED : Color.disabled)
                                    .imageScale(.medium)
                                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            }
                        }).contentShape(Rectangle())
                            .background(Color.deepRed)
                            .tint(.clear)
                    }
                }
                .ignoresSafeArea(edges: .top)
                .scrollIndicators(.hidden)
            }
        }.ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    dismiss()
                }, label: {
                    HStack(spacing: 5){
                        Text("DONE")
                            .font(.custom(FontNames.tungstenMedium, size: 22))
                    }.foregroundStyle(Color.white)
                }).padding()
            }
            
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Image("ValorantLogo")
                }.foregroundStyle(Color.white)
                    .padding()
            }
        }
        .toolbarBackground(.hidden)
    }
}

struct MiniMapView: View {
    var miniMap: String?
    var bgImage: String?
    
    var body: some View {
        ZStack {
            if let bgImage = bgImage, let url = URL(string: bgImage) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
            }
            
            // Minimap image
            if let miniMap = miniMap, let url = URL(string: miniMap) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .padding()
                        
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(1, contentMode: .fit)
                        .padding()
                        .clipShape(Circle())
                }
            }
        }
        .clipped()
    }
}

struct ImageCarouselView: View {
    @Binding var selection: Int
    var mapImages: [URL]
    
    var body: some View {
        TabView(selection : $selection) {
            ForEach(0..<mapImages.count, id: \.self) { index in
                let url = mapImages[index]
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

struct MapInfo: View {
    let map: Map
    let pageCount: Int
    @Binding var currentPage: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Page indicator
            HStack {
                ForEach(0..<pageCount, id: \.self) { index in
                    let isSelected = (currentPage == index)
                    Capsule()
                        .fill(isSelected ? .white : .white.opacity(0.5))
                        .frame(width: isSelected ? 24 : 8, height: 8)
                        .animation(.spring(), value: currentPage)
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(map.displayName.uppercased())
                    .font(.custom("Tungsten-Bold", size: 80))

                Text("LOCATION: \(map.coordinates ?? "UNKNOWN")")
                    .font(.custom("Tungsten-Light", size: 20))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .padding(30)
    }
}

#Preview {
    NavigationView(content: {
        SingleMapView(map: mockMap)
    })
}

#Preview {
    MiniMapView(
        miniMap: mockMap.displayIcon,
        bgImage: mockMap.premierBackgroundImage
    )
}
