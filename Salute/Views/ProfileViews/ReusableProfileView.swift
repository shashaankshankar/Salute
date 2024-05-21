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
                LazyVStack(alignment: .leading, spacing: 15) {
                    profileHeader
                    followersFollowingSection
                    Text("Wines Collected: ").fontWeight(.semibold) + Text("\(user.wineCount)")
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
        HStack(spacing: 15) {
            profileImage
            VStack(alignment: .leading, spacing: 5) {
                Text(user.name)
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("@\(user.username)")
                    .font(.subheadline)
                    .fontWeight(.light)
            }
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
        .frame(width: 75, height: 75)
        .clipShape(Circle())
        .background(Circle().stroke(Color.gray, lineWidth: 2))
    }
    
    private var followersFollowingSection: some View {
        HStack(spacing: 25) {
            NavigationLink(destination: FollowersFollowingView(user: user, selectionIndex: 0)) {
                Text("\(user.followers)").fontWeight(.semibold).foregroundColor(.black) + Text(" Followers").foregroundStyle(.gray)
            }
            NavigationLink(destination: FollowersFollowingView(user: user, selectionIndex: 1)) {
                Text("\(user.following)").fontWeight(.semibold).foregroundColor(.black) + Text(" Following").foregroundStyle(.gray)
            }
            if forCurrentUser == false {
                followButton
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
                if memoryViewModel.memories.count <= 1 {
                    Text("Memories")
                        .font(.title)
                        .fontWeight(.semibold)
                    Divider()
                    MemoriesList(hasMultipleMemories: false)
                } else {
                    Divider()
                    NavigationLink(destination: NavigationStack { MemoriesList(hasMultipleMemories: true) }.navigationTitle("Memories")) {
                        VStack(spacing: 15) {
                            // Label
                            HStack() {
                                Text("Memories")
                                    .font(.system(size: 20, weight: .bold))
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            HStack() {
                                memoryImage(url: memoryViewModel.memories[0].images[0])
                                memoryImage(url: memoryViewModel.memories[1].images[0], overlayText: "+\(memoryViewModel.memories.count - 1)")
                            }
                            .frame(height: 200)
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
                if wineViewModel.wineCollection.count <= 1 {
                    Text("Wine Collection")
                        .font(.title)
                        .fontWeight(.semibold)
                    Divider()
                    CollectionList(hasMultipleBottles: false)
                } else {
                    NavigationLink(destination: NavigationStack { CollectionList(hasMultipleBottles: true) }.navigationTitle("Wine Collection"))
                    {
                        VStack(spacing: 15) {
                            // Label
                            HStack() {
                                Text("Wine Collection")
                                    .font(.system(size: 20, weight: .bold))
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            HStack(spacing: 10) {
                                wineCard(bottle: wineViewModel.wineCollection[0])
                                wineCard(bottle: wineViewModel.wineCollection[1], overlayText: "+\(wineViewModel.wineCollection.count - 1)")
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
    }
    
    private func wineCard(bottle: WineBottle, overlayText: String? = nil) -> some View {
        NavigationLink(destination: BottleDetailView(userID: user.uid, wineBottle: bottle)) {
            WineCard(bottle: .collection(bottle), isVertical: true, verticalCardWidth: 150, verticalImageHeight: 150)
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
    func MemoriesList(hasMultipleMemories: Bool) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .center, spacing: 15) {
                if memoryViewModel.memories.isEmpty {
                    Text("No Memories Found")
                        .foregroundColor(.gray)
                } else {
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
                            .padding(.horizontal, hasMultipleMemories ? 15 : 0)
                            .id(id)
                            .onAppear {
                                if memory == memoryViewModel.memories.last && !isFetchingMore {
                                    fetchMoreMemories()
                                }
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
    func CollectionList(hasMultipleBottles: Bool) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 175))], spacing: 10) { // [GridItem(.flexible()), GridItem(.flexible())]
                if wineViewModel.filteredWineCollection.isEmpty {
                    Text("Collection is Empty")
                        .foregroundColor(.gray)
                } else {
                    ForEach(wineViewModel.filteredWineCollection.indices, id: \.self) { index in
                        NavigationLink(destination: BottleDetailView(userID: user.uid, wineBottle: wineViewModel.filteredWineCollection[index])) {
                            WineCard(bottle: .collection(wineViewModel.filteredWineCollection[index]), isVertical: true)
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }.padding()
        }
    }
}
