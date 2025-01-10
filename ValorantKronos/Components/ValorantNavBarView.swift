//
//  ValorantNavBarView.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/6/25.
//

import SwiftUI

struct ValorantNavBarView: View {
    @State private var selection = 2
    
    var body: some View {
        TabView (selection:$selection){
                CategoriesView()
                    .tabItem {
                        Image("CategoriesLogo")
                    }
                    .tag(1)
                MainView()
                    .tabItem {
                        Image("ValorantLogo")
                    }
                    .tag(2)
                    .ignoresSafeArea(edges: .top)
                SearchView()
                    .tabItem {
                        Image("SearchLogo")
                    }
                    .tag(3)
            }
            .tint(.almostWhite)
            .onAppear() {
                UITabBar.appearance().barTintColor = UIColor(.slightlyBlack)
                UITabBar.appearance().backgroundColor = UIColor(.slightlyBlack)
                UIScrollView.appearance().bounces = false
            }
    }
}


#Preview {
    ValorantNavBarView()
}
