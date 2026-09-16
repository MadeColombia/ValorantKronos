//
//  ValorantKronosApp.swift
//  ValorantKronos
//
//  Created by Ethan Montalvo on 3/01/25.
//  Updated for Core Data fast preload and startup initialization.
//

import SwiftUI

@main
struct ValorantKronosApp: App {
    @StateObject private var launchViewModel = AppLaunchViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if launchViewModel.isReady {
                    ValorantNavBarView()
                        .transition(.opacity)
                } else {
                    AppLaunchLoadingView(viewModel: launchViewModel)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.35), value: launchViewModel.isReady)
            .task {
                await launchViewModel.startInitialization()
            }
        }
    }
}
