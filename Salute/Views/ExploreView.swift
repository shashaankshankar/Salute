//
//  ExploreView.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/23/24.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            List {
                if authModel.filteredUsers.isEmpty {
                    ProgressView()
                } else {
                    ForEach(authModel.filteredUsers) { user in
                        NavigationLink(destination: ProfileView(userProfile: user)) {
                            ProfileCard(user: user)
                                .padding(.vertical)
                        }
                    }
                }
            }
            .searchable(text: $authModel.searchText)
            .navigationTitle("Explore")
        }
        .task {
            await authModel.fetchAllUsers()
            print("Fetched All Users")
        }
    }
}

//#Preview {
//    ExploreView()
//}
