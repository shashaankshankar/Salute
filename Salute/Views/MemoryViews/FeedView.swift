//
//  FeedView.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/17/24.
//

import SwiftUI
import Firebase

struct FeedView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    @StateObject private var memoryViewModel = MemoryViewModel()
    @State var recentMemories: [Memory] = []
    @State private var createNewMemory: Bool = false
    
    var body: some View {
        NavigationStack {
            MemoriesFeedView(memories: $recentMemories, memoryViewModel: memoryViewModel)
                .navigationTitle("Memories")
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        createNewMemory.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .background(.black, in: Circle())
                    }
                    .padding()
                }
        }
        .fullScreenCover(isPresented: $createNewMemory) {
            CreateMemoryView() { memory in
                recentMemories.insert(memory, at: 0)
            }
        }
    }
}
