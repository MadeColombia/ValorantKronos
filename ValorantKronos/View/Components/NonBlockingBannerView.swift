//
//  NonBlockingBannerView.swift
//  ValorantKronos
//
//  Created by Pair Programming Assistant on 15/09/26.
//  Subtle non-intrusive toast / banner alert for offline and refresh notifications.
//

import SwiftUI

public struct NonBlockingBannerView: View {
    public let message: String
    public var isWarning: Bool = true
    public var onDismiss: (() -> Void)? = nil
    
    public init(message: String, isWarning: Bool = true, onDismiss: (() -> Void)? = nil) {
        self.message = message
        self.isWarning = isWarning
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isWarning ? "wifi.exclamationmark" : "info.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isWarning ? .yellow : .white)
            
            Text(message)
                .font(.custom(FontNames.tungstenMedium, size: 16))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 4)
            
            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(4)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.slightlyBlack.opacity(0.95))
                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isWarning ? Color.yellow.opacity(0.5) : Color.valorantRED.opacity(0.5), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.3), value: message)
    }
}

struct NonBlockingBannerView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.almostWhite.ignoresSafeArea()
            VStack {
                NonBlockingBannerView(message: "Offline: Displaying cached data from Core Data.") {}
                Spacer()
            }
            .padding(.top, 50)
        }
    }
}
