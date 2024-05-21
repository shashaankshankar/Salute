//
//  TabBarView.swift
//  Salute
//
//  Created by Shashaank Shankar on 6/5/24.
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "rectangle.stack.fill")
                }
            
            CollectionView()
                .tabItem {
                    Label("Collection", systemImage: "wineglass")
                }
            
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "sparkle.magnifyingglass")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    TabBarView()
}
