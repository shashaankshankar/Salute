//
//  FollowersFollowingView.swift
//  Salute
//
//  Created by Shashaank Shankar on 8/3/24.
//

import SwiftUI

struct FollowersFollowingView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    var user: User
    @State var selectionIndex: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                SlidingTabView(selection: $selectionIndex,
                               tabs: ["Followers", "Following"],
                               font: .body,
                               activeAccentColor: Color.black,
                               selectionBarColor: Color.black) {
                    FollowersView(user: user)
                        .tag(0)
                    FollowingView(user: user)
                        .tag(1)
                }
                Spacer()
            }
        }
    }
}

struct FollowersView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    var user: User
    @State private var followers: [User] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if followers.isEmpty {
                Text("No Followers Found")
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            } else {
                List(followers) { follower in
                    NavigationLink(destination: ProfileView(userProfile: follower)) {
                        ProfileCard(user: follower)
                    }
                }                
            }
        }
        .onAppear {
            fetchFollowers()
        }
    }
    
    private func fetchFollowers() {
        Task {
            isLoading = true
            followers = await authModel.fetchFollowers(userID: user.uid)
            isLoading = false
        }
    }
}

struct FollowingView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    var user: User
    @State private var following: [User] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if following.isEmpty {
                Text("No Following Users Found")
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            } else {
                List(following) { followedUser in
                    NavigationLink(destination: ProfileView(userProfile: followedUser)) {
                        ProfileCard(user: followedUser)
                    }
                }
            }
        }
        .onAppear {
            fetchFollowing()
        }
    }
    
    private func fetchFollowing() {
        Task {
            isLoading = true
            following = await authModel.fetchFollowing(userID: user.uid)
            isLoading = false
        }
    }
}
