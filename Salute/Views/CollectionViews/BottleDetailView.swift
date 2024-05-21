//
//  BottleDetailView.swift
//  Salute
//
//  Created by Shashaank Shankar on 6/6/24.
//

import SwiftUI

struct BottleDetailView: View {
    @State private var isLoadingMemories = true
    @StateObject private var memoryViewModel = MemoryViewModel()
    @EnvironmentObject private var authModel: AuthViewModel
    var userID: String
    let wineBottle: WineBottle
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    bottleImage
                    content
                    locationMap
                    tastingNotes
                    if !memoryViewModel.memories.isEmpty {
                        memoriesSection
                    }
                }
                .padding(.bottom, 25)
            }
            .navigationTitle(wineBottle.winery ?? "")
            .onAppear {
                fetchData()
            }
        }
    }
}

// MARK: - Subviews

extension BottleDetailView {
    private var bottleImage: some View {
        VStack {
            AsyncImage(url: URL(string: wineBottle.image ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .shadow(radius: 1)
            } placeholder: {
                Image("wineSilhouette")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .shadow(radius: 1)
            }
            .frame(maxWidth: .infinity, maxHeight: 300)
            .padding(.vertical)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        wineBottle.wineTypeColor.opacity(0.025),
                        wineBottle.wineTypeColor.opacity(0.25)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(
                .rect(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 15,
                    bottomTrailingRadius: 15,
                    topTrailingRadius: 0,
                    style: .continuous
                )
            )
        }
        .padding(.horizontal)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(wineBottle.wine ?? "")
                .font(.system(size: 24))
                .fontWeight(.semibold)
            
            Divider()
            
            HStack(alignment: .top) {
                Text(wineBottle.formattedWineType)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(wineBottle.wineTypeColor)
                            .shadow(radius: 0.5)
                    )
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    HStack {
                        Text(wineBottle.formattedRatingAverage)
                            .font(.system(size: 24))
                        
                        StarRating(rating: Double(wineBottle.formattedRatingAverage)!.rounded(.toNearestOrAwayFromZero))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text(wineBottle.formattedRatingReviews)
                        .font(.system(size: 14))
                        .fontWeight(.light)
                }
            }
            
            VStack(spacing: 5) {
                Text(wineBottle.description ?? "No Description Available")
                    .font(.system(size: 16, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(descriptionBackground)
                
                PoweredByGemini
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    private var locationMap: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("🌐 \(wineBottle.formattedLocation)")
                .font(.system(size: 20, weight: .medium))
            
            MapView(location: wineBottle.formattedLocation)
                .frame(height: 300)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
    
    private var tastingNotes: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Tasting Notes")
                .font(.system(size: 20, weight: .medium))
            
            Divider()
            
            Text(wineBottle.tastingNotes ?? "No Tasting Notes Available")
                .font(.system(size: 16, weight: .regular))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(descriptionBackground)
            
            PoweredByGemini
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal)
    }
    
    private var memoriesSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            if isLoadingMemories {
                ProgressView()
            } else {
                if memoryViewModel.memories.count <= 1 {
                    Text("Memories")
                        .font(.system(size: 20, weight: .medium))
                    Divider()
                    MemoriesList(hasMultipleMemories: false)
                } else {
                    Divider()
                    NavigationLink(destination: NavigationStack { MemoriesList(hasMultipleMemories: true) }.navigationTitle("Memories")) {
                        VStack(spacing: 15) {
                            // Label
                            HStack() {
                                Text("Memories")
                                    .font(.system(size: 20, weight: .medium))
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
        .padding(.horizontal)
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
    
    private var descriptionBackground: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5), Color.pink.opacity(0.5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2
            )
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05), Color.pink.opacity(0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

// MARK: - Helper Views

private var PoweredByGemini: some View {
    HStack(spacing: 0) {
        Text("Powered by ")
            .font(.system(size: 12, weight: .light))
        
        Image("Google_Gemini_logo")
            .resizable()
            .scaledToFit()
            .frame(height: 14)
            .padding(.bottom, 3)
    }
}

// MARK: Data Fetching

extension BottleDetailView {
    private func fetchData() {
        Task {
            isLoadingMemories = true
            // Fetch memories when the view appears
            let memories = await memoryViewModel.fetchMemoriesForWineBottle(userID: userID, memoryIDs: wineBottle.memoryIDs)
            memoryViewModel.memories = memories
            isLoadingMemories = false
        }
    }
}

// MARK: Memories List

extension BottleDetailView {
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
                            let forCurrentUser: Bool = (userID == authModel.currentUser?.uid)
                            MemoryCard(memory: memory, forCurrentUser: forCurrentUser) { updatedMemory in
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
                        }
                    }
                }
            }
        }
    }
}
