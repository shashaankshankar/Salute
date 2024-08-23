//
//  ReusableProfileView.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/22/24.
//

import SwiftUI

struct ReusableProfileView: View {
    @State var user: User
    @State private var isLoadingMemories = true
    @State private var isLoadingCollection = true
    @StateObject private var memoryViewModel = MemoryViewModel()
    @StateObject private var wineViewModel = WineBottleViewModel()
    @EnvironmentObject private var authModel: AuthViewModel
    @State var isFetchingMore: Bool = false
    var forCurrentUser: Bool? = true
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .center, spacing: 15) {
                    profileHeader
                    userStatsSection
                    if forCurrentUser == false {
                        followButton
                    }
                    memoriesSection
                    wineCollectionSection
                }
                .padding()
            }
            .onAppear {
                fetchData()
            }
        }
    }
}

// MARK: Subviews

extension ReusableProfileView {
    private var profileHeader: some View {
        VStack(spacing: 15) {
            profileImage
            Text(user.name)
                .font(.title)
                .fontWeight(.semibold)
        }
    }
    
    private var profileImage: some View {
        ZStack {
            if let imageURL = user.profileImageURL, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image("DefaultProfilePicture").resizable().scaledToFill()
                }
            }
        }
        .frame(width: 100, height: 100)
        .clipShape(Circle())
        .background(Circle().stroke(Color.gray, lineWidth: 2))
    }
    
    private var userStatsSection: some View {
        HStack(spacing: 25) {
            NavigationLink(destination: FollowersFollowingView(user: user, selectionIndex: 0)) {
                VStack() {
                    Text("\(user.followers)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text("Followers")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            Divider()
            NavigationLink(destination: FollowersFollowingView(user: user, selectionIndex: 1)) {
                VStack() {
                    Text("\(user.following)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text("Following")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            Divider()
            VStack() {
                Text("\(user.wineCount)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                Text("Wines Collected")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
    }
    
    private var followButton: some View {
        Button(action: {
            authModel.toggleFollow(userID: user.uid)
            print("Follow Button Pressed")
        }, label: {
            Text(authModel.isFollowing(userID: user.uid) ? "Following" : "Follow")
                .fontWeight(.semibold)
                .padding(.horizontal)
                .padding(.vertical, 5)
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.black)
                )
        })
    }
    
    private var memoriesSection: some View {
        Group {
            if isLoadingMemories {
                ProgressView()
            } else {
                Divider()
                NavigationLink(destination: NavigationStack { MemoriesList() }.navigationTitle("Memories")) {
                    VStack(spacing: 15) {
                        // Label
                        HStack() {
                            Text("Memories")
                                .font(.system(size: 20, weight: .bold))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        if !memoryViewModel.memories.isEmpty {
                            Text("\(memoryViewModel.memories.count) Memories Posted")
                                .font(.callout)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text("No Memories Posted")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                    )
                }
                .tint(.black)
            }
        }
    }
    
    private func memoryImage(url: String, overlayText: String? = nil) -> some View {
        AsyncImage(url: URL(string: url)) { image in
            image.resizable().scaledToFit().cornerRadius(10)
        } placeholder: {
            ProgressView()
        }
        .overlay() {
            if let overlayText = overlayText {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.75))
                    .overlay(alignment: .center) {
                        Text(overlayText).fontWeight(.semibold)
                    }
            }
        }
    }
    
    private var wineCollectionSection: some View {
        Group {
            if isLoadingCollection {
                ProgressView()
            } else {
                NavigationLink(destination: NavigationStack { CollectionList() }.navigationTitle("Wine Collection")) {
                    VStack(spacing: 15) {
                        // Label
                        HStack() {
                            Text("Wine Collection")
                                .font(.system(size: 20, weight: .bold))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        if !wineViewModel.wineCollection.isEmpty {
                            HStack(spacing: 10) {
                                wineCard(bottle: wineViewModel.wineCollection[0])
                                if wineViewModel.wineCollection.count > 1 {
                                    wineCard(bottle: wineViewModel.wineCollection[1], overlayText: "+\(wineViewModel.wineCollection.count - 1)")
                                }
                            }
                        } else {
                            Text("No Wines Collected")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                    )
                }
                .tint(.black)
            }
        }
    }
    
    private func wineCard(bottle: WineBottle, overlayText: String? = nil) -> some View {
        NavigationLink(destination: BottleDetailView(userID: user.uid, wineBottle: bottle)) {
            WineCard(bottle: .collection(bottle), isVertical: true, verticalCardWidth: 150, verticalCardHeight: 200, verticalImageHeight: 150, includeText: false)
        }
        .overlay() {
            if let overlayText = overlayText {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.5))
                    .overlay(alignment: .center) {
                        Text(overlayText).fontWeight(.semibold)
                    }
            }
        }
    }
}

// MARK: Data Fetching

extension ReusableProfileView {
    private func fetchData() {
        Task {
            isLoadingCollection = true
            wineViewModel.fetchUserCollection(userID: user.uid)
            isLoadingCollection = false
        }
        Task {
            isLoadingMemories = true
            // Fetch memories when the view appears
            let memories = await memoryViewModel.fetchMemoriesForUser(userID: user.uid)
            memoryViewModel.memories = memories
            isLoadingMemories = false
        }
    }
}

// MARK: Memories List

extension ReusableProfileView {
    @ViewBuilder
    func MemoriesList() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            if memoryViewModel.memories.isEmpty {
                Text("No Memories Posted")
                    .font(.callout)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVStack(alignment: .center, spacing: 15) {
                    ForEach(memoryViewModel.memories, id: \.id) { memory in
                        if let id = memory.id {
                            MemoryCard(memory: memory, forCurrentUser: forCurrentUser!) { updatedMemory in
                                if let index = memoryViewModel.memories.firstIndex(where: { $0.id == updatedMemory.id }) {
                                    memoryViewModel.memories[index].likedIDs = updatedMemory.likedIDs
                                }
                            } onDelete: {
                                // Removing Memory from 'memoryViewModel.memories' array
                                memoryViewModel.memories.removeAll{ $0.id == id }
                                // Probably not live updating because the array is in the view model
                            }
                            .padding(5)
                            .padding(.horizontal)
                            .id(id)
                            .onAppear {
                                if memory == memoryViewModel.memories.last && !isFetchingMore {
                                    fetchMoreMemories()
                                }
                            }
                        }
                    }
                    
                    
                    if isFetchingMore {
                        ProgressView()
                            .padding(.top, 20)
                    }
                }
            }
        }
    }
    
    private func fetchMoreMemories() {
        guard !isFetchingMore else { return }
        isFetchingMore = true
        Task {
            let newMemories = await memoryViewModel.fetchMemoriesForUser(userID: user.uid, startAfterDoc: memoryViewModel.paginationDocs[user.uid]!)
            memoryViewModel.memories.append(contentsOf: newMemories.filter { newMemory in
                !memoryViewModel.memories.contains(where: { $0.id == newMemory.id })
            })
            print("Fetched More Memories")
            isFetchingMore = false
        }
    }
}

// MARK: Collection List

extension ReusableProfileView {
    @ViewBuilder
    func CollectionList() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            if wineViewModel.filteredWineCollection.isEmpty {
                Text("Collection is Empty")
                    .font(.callout)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 175))], spacing: 10) { // [GridItem(.flexible()), GridItem(.flexible())]
                    ForEach(wineViewModel.filteredWineCollection.indices, id: \.self) { index in
                        NavigationLink(destination: BottleDetailView(userID: user.uid, wineBottle: wineViewModel.filteredWineCollection[index])) {
                            WineCard(bottle: .collection(wineViewModel.filteredWineCollection[index]), isVertical: true)
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                        }
                        .buttonStyle(.plain)
                    }
                    
                }.padding()
            }
        }
    }
}
