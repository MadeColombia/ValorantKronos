//
//  AgentsView.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/11/25.
//

import SwiftUI

struct AgentsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AgentsViewModel()

    // UI-specific state remains in the view
    @State private var isExpanded: Bool = false
    @State private var showPrincipalTitle = false

    private let threeColumnGrid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    // Custom colors for the overlay for better readability
    private let overlayLightBorderColor = Color(red: 236/255, green: 234/255, blue: 235/255)
    private let overlayDarkShadowColor = Color(red: 192/255, green: 189/255, blue: 191/255)
    private let overlayLightShadowColor = Color.white

    var body: some View {
        ZStack {
            Color.almostWhite.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            } else {
                contentView
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .task {
            await viewModel.loadAgents()
        }
    }

    // MARK: - Extracted Views

    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // This GeometryReader tracks the scroll position to fade the title.
                GeometryReader { geo in
                    Color.clear.onChange(of: geo.frame(in: .global).minY) { _, newOffset in
                        showPrincipalTitle = newOffset <= 40
                    }
                }
                .frame(height: 0)

                DisclosureGroup(isExpanded: $isExpanded, content: { dropdownContent }, label: { dropdownLabel })
                    .tint(.clear)
                    .padding(.horizontal)

                LazyVGrid(columns: threeColumnGrid, spacing: 0) {
                                   ForEach(viewModel.filteredAgents, id: \.uuid) { agent in
                                       NavigationLink(destination: SingleAgentView(selectedAgent: agent)) {
                                           AgentCardView(agent: agent)
                                       }
                                   }
                               }
                .padding(.horizontal, 10)
            }
        }
    }

    private var dropdownLabel: some View {
        HStack {
            Text(viewModel.agentFilterOptions[viewModel.selectedRoleFilter] ?? "")
                .foregroundColor(.slightlyBlack)
                .font(.custom("Tungsten-Bold", size: 64))
                .lineLimit(1)
            Image(systemName: "arrowtriangle.up.fill")
                .foregroundColor(.black)
                .imageScale(.large)
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
        }
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
        .opacity(showPrincipalTitle ? 0 : 1)
    }

    private var dropdownContent: some View {
        VStack(spacing: 5) {
            ForEach(viewModel.agentFilterOptions.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                dropdownOptionRow(key: key, value: value)
            }
        }
        .padding()
        .background(Color.almostWhite)
        .overlay(
            RoundedRectangle(cornerRadius: 20) // Apply stroke and shadows to a RoundedRectangle
               .stroke(overlayLightBorderColor, lineWidth: 5)
               .shadow(color: overlayDarkShadowColor, radius: 4, x: 5, y: 5)
               .shadow(color: overlayLightShadowColor, radius: 4, x: -2, y: -2)
               .clipShape(RoundedRectangle(cornerRadius: 20)) // Clip to rounded rectangle shape
        )
    }

    private func dropdownOptionRow(key: String, value: String) -> some View {
        HStack {
            Text(value)
            Spacer()
            Image(systemName: "checkmark")
                .opacity(viewModel.selectedRoleFilter == key ? 1 : 0)
        }
        .foregroundStyle(viewModel.selectedRoleFilter == key ? Color.valorantBlack : Color.gray)
        .animation(.none, value: viewModel.selectedRoleFilter)
        .contentShape(Rectangle())
        .padding(.horizontal, 10)
        .onTapGesture {
            withAnimation(.snappy) {
                viewModel.selectedRoleFilter = key
                isExpanded.toggle()
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
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
            Text(viewModel.agentFilterOptions[viewModel.selectedRoleFilter] ?? "")
                .font(.custom(FontNames.tungstenSemiBold, size: 25))
                .opacity(showPrincipalTitle ? 1 : 0)
                .animation(.easeOut(duration: 0.2), value: showPrincipalTitle)
        }
    }
}

#Preview {
    NavigationView {
        AgentsView()
    }
}
