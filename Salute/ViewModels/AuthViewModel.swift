//
//  AuthViewModel.swift
//  Salute
//
//  Created by Shashaank Shankar on 6/5/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var user: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var fetchedUsers: [User] = [] // All Users
    @Published var isPasswordResetEmailSent = false
    @Published var searchText: String = ""
    private let database = Firestore.firestore()
    
    var filteredUsers: [User] {
        let filteredBySearch = fetchedUsers.filter {
            searchText.isEmpty || ($0.name.localizedCaseInsensitiveContains(searchText)) || ($0.username.localizedCaseInsensitiveContains(searchText))
        }
        return filteredBySearch
    }
    
    // Check if User is Authenticated
    func authState() {
        Auth.auth().addStateDidChangeListener{ [weak self] _, user in
            guard let self = self else { return }
            self.user = user
            if let user = user {
                Task {
                    await self.fetchCurrentUserData()
                }
            }
        }
    }
    
    // Sign-In Function
    func signIn(email: String, password: String) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            defer { self?.isLoading = false }
            if let error = error {
                print("an error occurred: \(error.localizedDescription)")
                return
            }
        }
    }
    
    // Sign-Up Function
    func signUp(email: String, password: String, name: String, username: String, profileImage: Data?) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            defer { self?.isLoading = false }
            guard let self = self else { return }
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                return
            }
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            // Upload Profile Image
            if let profileImageData = profileImage {
                let storageRef = Storage.storage().reference()
                let imageRef = storageRef.child("profileImages/\(uid).jpg")
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                imageRef.putData(profileImageData, metadata: metadata) { (metadata, error) in
                    if let error = error {
                        print("Error uploading image: \(error.localizedDescription)")
                    } else {
                        imageRef.downloadURL { (url, error) in
                            guard let downloadURL = url else {
                                print("Error getting download URL: \(error?.localizedDescription ?? "")")
                                return
                            }
                            
                            self.storeUserData(uid: uid, email: email, name: name, username: username, profileImageURL: downloadURL.absoluteString)
                        }
                    }
                }
            } else {
                self.storeUserData(uid: uid, email: email, name: name, username: username, profileImageURL: nil)
            }
        }
    }
    
    // Logout Function
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    // Reset Password Function
    func resetPassword(email: String, completion: @escaping (Error?) -> Void) { // Add completion handler
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            // Handle error (display an alert, etc.)
            print("Error resetting password: \(error?.localizedDescription ?? "Unknown error")")
            completion(error) // Pass the error to the completion handler
        }
    }
    
    // Return Logged in User Details
    func fetchCurrentUserData() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            // Handle the case where there is no currently signed-in user
            print("No user currently signed in.")
            return
        }
        
        let userDocRef = database.collection("Users").document(uid)
        let user = try? await userDocRef.getDocument(as: User.self)
        
        await MainActor.run(body: {
            self.currentUser = user
        })
        print("Fetched Current User Data: \(self.currentUser?.uid ?? "")")
    }
    
    // Return Given User Details
    func fetchUserData(userID: String, completion: @escaping (User) -> Void) async {
        let userDocRef = database.collection("Users").document(userID)
        let user = (try? await userDocRef.getDocument(as: User.self))!
        completion(user)
    }
    
    // Fetch all Users
    func fetchAllUsers() async {
        do {
            let snapshot = try await database.collection("Users").getDocuments()
            let users = try snapshot.documents.compactMap {
                try $0.data(as: User.self)
            }.filter { $0.uid != Auth.auth().currentUser?.uid }
            DispatchQueue.main.async {
                self.fetchedUsers = users
            }
        } catch {
            print("Error fetching users: \(error)")
        }
    }
        
    // Store User Data
    private func storeUserData(uid: String, email: String, name: String, username: String, profileImageURL: String?) {
        let user = User(
            uid: uid, 
            email: email,
            username: username,
            name: name,
            profileImageURL: profileImageURL,
            wineCount: 0,
            followers: 0,
            following: 0,
            followingUserIDs: []
        )
        
        do {
            try database.collection("Users").document(uid).setData(from: user)
            self.currentUser = user
            print("Successfully created user with ID \(uid)")
        } catch {
            print("Error storing user data: \(error.localizedDescription)")
        }
    }
    
    // Check if User is Followed
    func isFollowing(userID: String) -> Bool {        
        return self.currentUser?.followingUserIDs.contains(userID) ?? false
    }
    
    // Follow/Unfollow a User
    func toggleFollow(userID: String) {
        guard let currentUserID = self.currentUser?.uid else { return }
        if isFollowing(userID: userID) {
            // Unfollow
            self.currentUser?.followingUserIDs.removeAll(where: { $0 == userID })
            updateFollowingAndFollowers(currentUserID: currentUserID, userIDToFollow: userID, followingValue: Int64(-1), followerValue: Int64(-1))
            print("Unfollowed User", userID)
        } else {
            // Follow
            self.currentUser?.followingUserIDs.append(userID)
            updateFollowingAndFollowers(currentUserID: currentUserID, userIDToFollow: userID, followingValue: Int64(1), followerValue: Int64(1))
            print("Followed User", userID)
        }
        
        // Reload current user's data to reflect changes
        Task {
            await fetchCurrentUserData()
        }
    }
    
    // Update Following and Follower Counts
    private func updateFollowingAndFollowers(currentUserID: String, userIDToFollow: String, followingValue: Int64, followerValue: Int64){
        database.collection("Users").document(currentUserID).updateData([
            "followingUserIDs": self.currentUser?.followingUserIDs ?? [],
            "following": FieldValue.increment(followingValue)
        ])
        database.collection("Users").document(userIDToFollow).updateData([
            "followers": FieldValue.increment(followerValue)
        ])
    }
    
    func fetchFollowers(userID: String) async -> [User] {
        do {
            let snapshot = try await database.collection("Users").whereField("followingUserIDs", arrayContains: userID).getDocuments()
            return snapshot.documents.compactMap{ try? $0.data(as: User.self) }
        } catch {
            print("Error Fetching Followers: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchFollowing(userID: String) async -> [User] {
        do {
            let userDoc = try await database.collection("Users").document(userID).getDocument()
            guard let user = try? userDoc.data(as: User.self) else { return [] }
            let followingIDs = user.followingUserIDs
            if followingIDs.isEmpty { return [] }
            let snapshot = try await database.collection("Users").whereField("uid", in: followingIDs).getDocuments()
            return snapshot.documents.compactMap{ try? $0.data(as: User.self) }
        } catch {
            print("Error Fetching Followers: \(error.localizedDescription)")
            return []
        }
    }
}
