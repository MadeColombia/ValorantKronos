//
//  WeaponsView.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/11/25.
//

import SwiftUI

struct WeaponsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = WeaponsViewModel()
    // Removed unused 'weapons' property NEED TO BE ADDED BACK LATER
    
    var body: some View {
            ZStack(alignment: .top) {
                Color.deepRed
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 44))
                            .foregroundStyle(.white.opacity(0.7))
                        Text(errorMessage)
                            .font(.custom(FontNames.tungstenMedium, size: 20))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button {
                            Task { await viewModel.loadWeapons(forceRefresh: true) }
                        } label: {
                            Text("RETRY")
                                .font(.custom(FontNames.tungstenBold, size: 22))
                                .foregroundStyle(Color.deepRed)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                } else {
                    VStack {
                        HStack {
                            Text("WEAPONS")
                                .foregroundColor(Color.valorantRED)
                                .font(.custom("Tungsten-Bold", size: 64))
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(.bottom, 5)
                        
                        ScrollView(.vertical) {
                            ForEach(CATEGORY.allCases) { categoryState in
                                DropdownMenuDisclosureGroup(
                                    weapons: viewModel.weapons(for: categoryState),
                                    title: categoryState.displayName
                                )
                            }
                        }
                        .refreshable {
                            await viewModel.loadWeapons(forceRefresh: true)
                        }
                        .scrollIndicators(.hidden)
                        .scrollTargetBehavior(.viewAligned)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                
                if let alert = viewModel.nonBlockingAlertMessage {
                    NonBlockingBannerView(message: alert, isWarning: true) {
                        viewModel.clearNonBlockingAlert()
                    }
                    .padding(.top, 10)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        HStack(spacing: 5){
                            Image(systemName: "chevron.backward")
                            Text("BACK")
                                .font(.custom(FontNames.tungstenMedium, size: 22))
                        }.foregroundStyle(Color.white)
                    })
                }
            }
            .task {
                await viewModel.loadWeapons()
            }
    }
}

struct DropdownMenuDisclosureGroup: View {
    @State private var isExpanded: Bool = false
    var weapons: [Weapon] 
    let title: String

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ScrollView(.horizontal) {
                LazyHStack(alignment: .center, spacing: 30) {
                    ForEach(weapons) { weapon in
                        NavigationLink(destination: SingleWeaponView(weapon: weapon)) {
                            LargeCardView(title: weapon.displayName, portraitImage: weapon.displayIcon ?? "placeholderImageName", isHorizontal: false)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .padding(.vertical)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
        } label: {
            HStack {
                Text(title)
                    .foregroundColor(isExpanded ? Color.almostWhite : Color.disabled)
                    .font(.custom("Tungsten-Bold", size: 48))
                    .lineLimit(1)
    
                Image(systemName: "arrowtriangle.up.fill")
                    .foregroundColor(isExpanded ? Color.almostWhite : Color.disabled)
                    .imageScale(.large)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .animation(.easeInOut(duration: 0.2), value: isExpanded)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
        }.tint(.clear)
    }
}

#Preview {
    NavigationView {
        WeaponsView()
    }
}
