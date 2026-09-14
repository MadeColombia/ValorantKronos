//
//  CategoriesView.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/6/25.
//

import SwiftUI

// MARK: - Category Entry Model

private struct CategoryEntry: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    let destination: AnyView
}

// MARK: - CategoriesView

struct CategoriesView: View {
    private let categories: [CategoryEntry] = [
        CategoryEntry(
            title: "AGENTS",
            subtitle: "Duelists, Controllers, Initiators & Sentinels",
            imageName: "AgentsImage",
            destination: AnyView(AgentsView())
        ),
        CategoryEntry(
            title: "WEAPONS",
            subtitle: "Sidearms, Rifles, SMGs, Snipers & Heavy",
            imageName: "WeaponsImage",
            destination: AnyView(WeaponsView())
        ),
        CategoryEntry(
            title: "MAPS",
            subtitle: "Every battleground in the game",
            imageName: "MapsImage",
            destination: AnyView(MapsView())
        ),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.slightlyBlack.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("CATEGORIES")
                            .font(.custom(FontNames.tungstenBold, size: 64))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 4)

                        VStack(spacing: 16) {
                            ForEach(categories) { category in
                                NavigationLink(destination: category.destination) {
                                    CategoryCard(entry: category)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - CategoryCard

private struct CategoryCard: View {
    let entry: CategoryEntry

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background fills the card bounds
            Image(entry.imageName)
                .resizable()
                .scaledToFill()
                .clipped()

            // Dark gradient so text is always readable
            LinearGradient(
                colors: [Color.black.opacity(0.78), Color.black.opacity(0.05)],
                startPoint: .bottom,
                endPoint: .top
            )

            // Text overlay pinned to bottom-left
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.custom(FontNames.tungstenBold, size: 44))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(entry.subtitle)
                    .font(.custom(FontNames.tungstenMedium, size: 15))
                    .foregroundStyle(Color.white.opacity(0.80))
                    .lineLimit(2)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .background(Color.valorantBlack)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 3)
    }
}

#Preview {
    CategoriesView()
}
