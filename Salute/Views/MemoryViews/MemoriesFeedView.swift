//
//  MemoriesFeedView.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/30/24.
//

import SwiftUI
import Firebase

struct MemoriesFeedView: View {
    @Binding var memories: [Memory]
    @State var isFetching: Bool = true
    @State var isFetchingMore: Bool = false
    @EnvironmentObject private var authModel: AuthViewModel
    @ObservedObject var memoryViewModel: MemoryViewModel
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                if isFetching {
                    ProgressView()
                        .padding(.top, 20)
                } else {
                    if memories.isEmpty {
                        Text("No Memories Found")                            
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                    } else {
                        Memories()
                    }
                }
                
                if isFetchingMore {
                    ProgressView()
                        .padding(.top, 20)
                }
            }
        }
        .refreshable {
            isFetching = true
            Task {
                let memories = await memoryViewModel.fetchMemoriesForFeed(followingUserIDs: authModel.currentUser?.followingUserIDs ?? [], resetPagination: true)
                self.memories = memories
                isFetching = false
            }
        }
        .onAppear {
            guard memories.isEmpty else { return }
            if let _ = authModel.currentUser {
                Task {
                    let memories = await memoryViewModel.fetchMemoriesForFeed(followingUserIDs: authModel.currentUser?.followingUserIDs ?? [], resetPagination: true)
                    self.memories = memories
                    isFetching = false
                }
            }
        }
        .onChange(of: authModel.currentUser) { _,_ in
            Task {
                let memories = await memoryViewModel.fetchMemoriesForFeed(followingUserIDs: authModel.currentUser?.followingUserIDs ?? [], resetPagination: true)
                self.memories = memories
                isFetching = false
                memoryViewModel.paginationDocs = [:]
            }
        }
    }
    
    @ViewBuilder
    func Memories() -> some View {
        ForEach(memories, id: \.id) { memory in
            if let id = memory.id {
                MemoryCard(memory: memory, forCurrentUser: false) { updatedMemory in
                    // Updating Memory in 'memories' array
                    if let index = memories.firstIndex(where: { $0.id == updatedMemory.id }) {
                        memories[index].likedIDs = updatedMemory.likedIDs
                    }
                } onDelete: {
                    // Removing Memory from 'memories' array
                    memories.removeAll{ $0.id == id }
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .id(id)
                .onAppear {
                    if memory == memories.last {
                        fetchMoreMemories()
                    }
                }
            }
        }
    }
    
    private func fetchMoreMemories() {
        isFetchingMore = true
        Task {            
            let newMemories = await memoryViewModel.fetchMemoriesForFeed(followingUserIDs: authModel.currentUser?.followingUserIDs ?? [])
            self.memories.append(contentsOf: newMemories.filter { newMemory in
                !self.memories.contains(where: { $0.id == newMemory.id })
            })
            print("Fetched More Memories")
            isFetchingMore = false
        }
    }
}

//#Preview {
//    FeedView()
//}
