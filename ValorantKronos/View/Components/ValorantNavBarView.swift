//
//  ValorantNavBarView.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/6/25.
//

import SwiftUI

struct ValorantNavBarView: View {
    @State private var selection = 2 // Default selected tab
    
    // State variables to hold unique IDs for each tab's content view.
    // Changing these IDs will cause SwiftUI to recreate the respective view.
    @State private var categoriesViewID = UUID()
    @State private var mainViewID = UUID()
    @State private var searchViewID = UUID()
    
    var body: some View {
        TabView(selection: Binding(
            get: { self.selection },
            set: { newSelection in
                // Check if the user is tapping the already selected tab
                if newSelection == self.selection {
                    // If so, update the ID of the corresponding view to trigger a reset
                    switch newSelection {
                    case 1:
                        self.categoriesViewID = UUID()
                    case 2:
                        self.mainViewID = UUID()
                    case 3:
                        self.searchViewID = UUID()
                    default:
                        break
                    }
                }
                // Always update the selection state
                self.selection = newSelection
            }
        )) {
            CategoriesView()
                .id(self.categoriesViewID) // Assigning an ID to the view
                .transition(.opacity) // Added transition for dismiss/appear animation
                .tabItem {
                    Image("CategoriesLogo")
                }
                .tag(1)
            
            MainView()
                .id(self.mainViewID) // Assigning an ID to the view
                .transition(.opacity) // Added transition for dismiss/appear animation
                .tabItem {
                    Image("ValorantLogo")
                }
                .tag(2)
            
            SearchView()
                .id(self.searchViewID) // Assigning an ID to the view
                .transition(.opacity) // Added transition for dismiss/appear animation
                .tabItem {
                    Image("SearchLogo")
                }
                .tag(3)
        }
        .tint(.almostWhite)
        .onAppear() {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor(.slightlyBlack)
            
            UITabBar.appearance().standardAppearance = tabBarAppearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
            
            // This globally disables bouncing for all ScrollViews
            UIScrollView.appearance().bounces = false
        }
    }
}

#Preview {
    NavigationView {
        ValorantNavBarView()
    }
}
