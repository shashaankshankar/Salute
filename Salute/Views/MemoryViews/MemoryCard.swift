//
//  MemoryCard.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/26/24.
//

import SwiftUI
import Firebase

struct MemoryCard: View {
    @EnvironmentObject private var authModel: AuthViewModel
    @ObservedObject private var wineBottleViewModel = WineBottleViewModel()
    @ObservedObject private var memoryViewModel = MemoryViewModel()
    @State private var docListener: ListenerRegistration?
    @State var user: User?
    @State var wineBottles: [WineBottle] = []
    var memory: Memory
    var forCurrentUser: Bool = true
    
    // Callbacks
    var onUpdate: (Memory) -> ()
    var onDelete: () -> ()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if let user = user {
                headerView(user: user)
            }
            
            Divider()
            
            imagesView
            
            Divider()
            
            likesView
            
            if let caption = memory.caption, let user = user, !caption.isEmpty {
                captionView(user: user)
            }
            
            if !wineBottles.isEmpty {
                Divider()
                wineBottlesView
            }
        }
        .padding()
        .background(cardBackground)
        .task { await fetchUserData(); await fetchMemoryWineBottles() }
        .onAppear { addSnapshotListener() }
        .onDisappear { removeSnapshotListener() }
    }
}

// MARK: - Subviews

extension MemoryCard {
    private func headerView(user: User) -> some View {
        HStack {
            NavigationLink(destination: ProfileView(userProfile: user)) {
                userProfileImageView(user: user)
                userNameView(user: user)
            }
            Spacer()
            menuButton
        }
    }
    
    private func userProfileImageView(user: User) -> some View {
        ZStack {
            if let imageURL = user.profileImageURL, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image("DefaultProfilePicture")
                        .resizable()
                        .scaledToFill()
                }
            }
        }
        .frame(width: 35, height: 35)
        .clipShape(Circle())
        .contentShape(Circle())
        .background(Circle().stroke(Color.gray, lineWidth: 2))
    }
    
    private func userNameView(user: User) -> some View {
        Text(user.username)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.black)
    }
    
    private var menuButton: some View {
        Menu {
            if !forCurrentUser {
                Button("Share Memory", action: {})
            } else {
                Button("Delete Memory", role: .destructive, action: deleteMemory)
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 18))
                .tint(.black)
        }
    }
    
    private var imagesView: some View {
        TabView {
            ForEach(memory.images, id: \.self) { imageURL in
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                }
            }
        }
        .frame(height: 400)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .interactive))
    }
    
    private var likesView: some View {
        let isLiked = memory.likedIDs?.contains(authModel.currentUser?.uid ?? "") ?? false
        
        return HStack(spacing: 10) {
            if !forCurrentUser {
                Button(action: toggleLike) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .black)
                }
            } else {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundColor(isLiked ? .red : .black)
            }
            Text("\(memory.likedIDs?.count ?? 0)")
                .fontWeight(.light)
            Spacer()
            Text(memory.datePublished, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func captionView(user: User) -> some View {
        Text("\(user.username) ")
            .font(.system(size: 16, weight: .semibold))
        +
        Text(memory.caption ?? "")
            .font(.system(size: 16, weight: .regular))
    }
    
    private var wineBottlesView: some View {
        TabView {
            
            ForEach(wineBottles.indices, id: \.self) { index in
                let wineBottle: WineBottle = wineBottles[index]
                NavigationLink(destination: BottleDetailView(userID: memory.userID, wineBottle: wineBottle)) {
                    WineCard(bottle: .collection(wineBottle), isVertical: false, horizontalImageWidth: 40)
                        .padding(5)
                        .tint(.black)
                        .overlay(alignment: .topTrailing) { wineBottleIndexOverlay(index: index) }
                }
                .id("\(wineBottle.id ?? "default")-\(index)")
            }
        }
        .frame(height: 185)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
    
    private func wineBottleIndexOverlay(index: Int) -> some View {
        Text("\(index + 1)/\(wineBottles.count)")
            .font(.system(size: 12))
            .foregroundColor(.white)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.5))
                    .frame(width: 40, height: 20)
            )
            .padding()
            .padding(.horizontal, 10)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(.white)
            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Helper Methods

extension MemoryCard {
    private func fetchUserData() async {
        if user == nil {
            await authModel.fetchUserData(userID: memory.userID) { user in
                self.user = user
            }
        }
    }
    
    private func fetchMemoryWineBottles() async {
        var wineBottles: [WineBottle] = []
        for wineBottleID in memory.wineBottleIDs {
            await withCheckedContinuation { continuation in
                wineBottleViewModel.fetchByID(userID: memory.userID, wineID: wineBottleID) { wineBottle in
                    if let wineBottle = wineBottle {
                        wineBottles.append(wineBottle)
                    }
                    continuation.resume()
                }
            }
        }
        self.wineBottles = wineBottles
    }
    
    private func addSnapshotListener() {
        guard docListener == nil, let memoryID = memory.id else { return }
        docListener = Firestore.firestore().collection("Users").document(memory.userID)
            .collection("Memories").document(memoryID)
            .addSnapshotListener { snapshot, error in
                if let snapshot {
                    if snapshot.exists {
                        if let updatedMemory = try? snapshot.data(as: Memory.self) {
                            onUpdate(updatedMemory)
                        }
                    } else {
                        onDelete()
                    }
                }
            }
    }
    
    private func removeSnapshotListener() {
        docListener?.remove()
        docListener = nil
    }
    
    private func toggleLike() {
        Task {
            await memoryViewModel.toggleLikeForMemory(memory: memory, userID: authModel.currentUser?.uid ?? "")
        }
    }
    
    private func deleteMemory() {
        Task {
            do {
                try await memoryViewModel.deleteMemory(memory: memory)
                onDelete()
            } catch {
                print("Failed to Delete Memory: \(error.localizedDescription)")
            }
        }
    }
}
