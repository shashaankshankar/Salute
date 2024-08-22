//
//  ProfileView.swift
//  Salute
//
//  Created by Shashaank Shankar on 6/5/24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var userProfile: User?
    @EnvironmentObject private var authModel: AuthViewModel
    var body: some View {
        NavigationStack {
            VStack() {
                if let givenUserProfile = self.userProfile {
                    ReusableProfileView(user: givenUserProfile, forCurrentUser: false)
                }
                else if let currentUserProfile = authModel.currentUser {
                    ReusableProfileView(user: currentUserProfile)
                        .refreshable {
                            Task {
                                await authModel.fetchCurrentUserData()
                            }
                        }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(userProfile == nil ? "Profile" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if (userProfile == nil) {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button("Logout") {
                                authModel.logout()
                            }
                            Button("Delete Account", role: .destructive) {
                                
                            }
                        } label: {
                            Image(systemName: "gear")
//                                .rotationEffect(.degrees(90))
                                .tint(.black)
                        }
                    }
                }
            }
        }
    }
}
