//
//  ValorantBackButton.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 23/09/26.
//  Standardized chevron back button with circular contrast background and no text.
//

import SwiftUI

public struct ValorantBackButton: View {
    @Environment(\.dismiss) private var dismiss
    
    /// When true, renders dark chevron for bright/white screens (e.g., AgentsView, MapsView).
    /// When false, renders white chevron for dark screens (e.g., WeaponsView, SingleAgentView, SingleWeaponView).
    public var isLight: Bool
    
    /// Optional custom dismiss handler. When nil, calls `dismiss()`.
    public var action: (() -> Void)?
    
    public init(isLight: Bool = false, action: (() -> Void)? = nil) {
        self.isLight = isLight
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            if let action = action {
                action()
            } else {
                dismiss()
            }
        }) {
            Image(systemName: "chevron.backward")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(isLight ? Color.slightlyBlack : Color.white)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isLight ? Color.black.opacity(0.08) : Color.white.opacity(0.18))
                )
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}

#Preview {
    ZStack {
        Color.slightlyBlack.ignoresSafeArea()
        HStack(spacing: 20) {
            ValorantBackButton(isLight: false)
            ValorantBackButton(isLight: true)
                .background(Color.almostWhite)
        }
    }
}
