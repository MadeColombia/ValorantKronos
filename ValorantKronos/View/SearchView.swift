//
//  SearchView.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/6/25.
//

import SwiftUI

// MARK: - SearchView

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.slightlyBlack.ignoresSafeArea()

                VStack(spacing: 0) {
                    // ── Search bar ──────────────────────────────────────
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.gray)
                        TextField("Search agents, weapons, maps…", text: $searchText)
                            .foregroundStyle(Color.white)
                            .tint(Color.valorantRED)
                            .autocorrectionDisabled()
                            .onSubmit { viewModel.searchText = searchText }
                            .onChange(of: searchText) { _, new in
                                viewModel.searchText = new
                            }
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                viewModel.searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 10)

                    // ── Scope Picker ────────────────────────────────────
                    SearchScopePicker(selected: $viewModel.selectedScope)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)

                    // ── Content ─────────────────────────────────────────
                    if viewModel.isLoading && !viewModel.isDataLoaded {
                        // True cold start — nothing cached yet
                        Spacer()
                        ProgressView()
                            .tint(Color.valorantRED)
                            .scaleEffect(1.3)
                        Spacer()

                    } else if let errorMessage = viewModel.errorMessage, !viewModel.isDataLoaded {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "wifi.slash")
                                .font(.system(size: 44))
                                .foregroundStyle(Color.gray)
                            Text(errorMessage)
                                .font(.custom(FontNames.tungstenMedium, size: 20))
                                .foregroundStyle(Color.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button {
                                Task { await viewModel.loadAllData(forceRefresh: true) }
                            } label: {
                                Text("RETRY")
                                    .font(.custom(FontNames.tungstenBold, size: 22))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 10)
                                    .background(Color.valorantRED)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        Spacer()

                    } else if viewModel.noResultsFound {
                        Spacer()
                        VStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.gray)
                            Text("No results for \"\(searchText)\"")
                                .font(.custom(FontNames.tungstenMedium, size: 22))
                                .foregroundStyle(Color.white.opacity(0.6))
                        }
                        Spacer()

                    } else if !viewModel.isDataLoaded {
                        Spacer()
                        VStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.gray.opacity(0.4))
                            Text("Search Agents, Weapons & Maps")
                                .font(.custom(FontNames.tungstenMedium, size: 20))
                                .foregroundStyle(Color.gray)
                        }
                        Spacer()

                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: []) {

                                // ── Agents ──────────────────────────────
                                if !viewModel.matchingAgents.isEmpty {
                                    SearchSectionHeader(title: "AGENTS")
                                    ForEach(viewModel.matchingAgents) { agent in
                                        NavigationLink(destination: SingleAgentView(selectedAgent: agent)) {
                                            AgentSearchRow(agent: agent)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }

                                // ── Weapons ─────────────────────────────
                                if !viewModel.matchingWeapons.isEmpty {
                                    SearchSectionHeader(title: "WEAPONS")
                                    ForEach(viewModel.matchingWeapons) { weapon in
                                        NavigationLink(destination: SingleWeaponView(weapon: weapon)) {
                                            WeaponSearchRow(weapon: weapon)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }

                                // ── Maps ────────────────────────────────
                                if !viewModel.matchingMaps.isEmpty {
                                    SearchSectionHeader(title: "MAPS")
                                    ForEach(viewModel.matchingMaps) { map in
                                        MapSearchRow(map: map)
                                    }
                                }
                            }
                            .padding(.bottom, 20)
                        }
                        .scrollIndicators(.hidden)
                        .refreshable {
                            await viewModel.loadAllData(forceRefresh: true)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SEARCH")
                        .font(.custom(FontNames.tungstenBold, size: 28))
                        .foregroundStyle(Color.white)
                }
            }
            .task {
                await viewModel.loadAllData()
            }
        }
    }
}

// MARK: - Scope Picker

private struct SearchScopePicker: View {
    @Binding var selected: SearchScope

    var body: some View {
        HStack(spacing: 6) {
            ForEach(SearchScope.allCases) { scope in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selected = scope
                    }
                } label: {
                    Text(scope.displayName)
                        .font(.custom(FontNames.tungstenSemiBold, size: 16))
                        .foregroundStyle(selected == scope ? .white : Color.white.opacity(0.5))
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity)
                        .background(
                            selected == scope
                                ? Color.valorantRED
                                : Color.clear
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.white.opacity(0.08))
        .clipShape(Capsule())
    }
}

// MARK: - Section Header

private struct SearchSectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.custom(FontNames.tungstenBold, size: 22))
            .foregroundStyle(Color.valorantRED)
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 6)
    }
}

// MARK: - Row Subviews

private struct AgentSearchRow: View {
    let agent: Agent
    var body: some View {
        HStack(spacing: 12) {
            CachedAsyncImage(url: URL(string: agent.fullPortrait ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure, .empty:
                    Image(systemName: "person.fill")
                        .resizable().scaledToFit()
                        .foregroundStyle(Color.gray)
                        .padding(8)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 48, height: 48)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(agent.displayName.uppercased())
                    .font(.custom(FontNames.tungstenBold, size: 22))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                if let role = agent.role?.displayName {
                    Text(role)
                        .font(.custom(FontNames.tungstenMedium, size: 14))
                        .foregroundStyle(Color.gray)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.gray.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.03))
        Divider()
            .background(Color.white.opacity(0.07))
            .padding(.leading, 76)
    }
}

private struct WeaponSearchRow: View {
    let weapon: Weapon
    var body: some View {
        HStack(spacing: 12) {
            CachedAsyncImage(url: URL(string: weapon.displayIcon ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFit().padding(6)
                case .failure, .empty:
                    Image(systemName: "bolt.fill")
                        .resizable().scaledToFit()
                        .foregroundStyle(Color.gray)
                        .padding(10)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 48, height: 48)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(weapon.displayName.uppercased())
                    .font(.custom(FontNames.tungstenBold, size: 22))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                Text(weapon.formattedCategory)
                    .font(.custom(FontNames.tungstenMedium, size: 14))
                    .foregroundStyle(Color.gray)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.gray.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.03))
        Divider()
            .background(Color.white.opacity(0.07))
            .padding(.leading, 76)
    }
}

private struct MapSearchRow: View {
    let map: Map
    var body: some View {
        HStack(spacing: 12) {
            CachedAsyncImage(url: URL(string: map.displayIcon ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill().clipped()
                case .failure, .empty:
                    Image(systemName: "map.fill")
                        .resizable().scaledToFit()
                        .foregroundStyle(Color.gray)
                        .padding(10)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 48, height: 48)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(map.displayName.uppercased())
                    .font(.custom(FontNames.tungstenBold, size: 22))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                Text("Map")
                    .font(.custom(FontNames.tungstenMedium, size: 14))
                    .foregroundStyle(Color.gray)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.03))
        Divider()
            .background(Color.white.opacity(0.07))
            .padding(.leading, 76)
    }
}

// MARK: - Preview

#Preview {
    SearchView()
}
