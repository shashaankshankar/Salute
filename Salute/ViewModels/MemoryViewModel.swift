//
//  MemoryViewModel.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/24/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class MemoryViewModel: ObservableObject {
    @Published var memories: [Memory] = []
    @Published var wineBottleViewModel: WineBottleViewModel = WineBottleViewModel()
    @Published var authViewModel: AuthViewModel = AuthViewModel()
    private let database = Firestore.firestore()
    var paginationDocs: [String: QueryDocumentSnapshot?] = [:]
    
    func createMemory(
        userID: String,
        wineBottles: [WineBottle],
        caption: String?,
        imageData: [Data],
        completion: @escaping (Memory) -> Void
    ) {
        var imageURLs: [String] = []
        let dispatchGroup = DispatchGroup()
        let memoryRef = database.collection("Users").document(userID).collection("Memories").document()
        let wineBottleIDs = wineBottles.compactMap { $0.id }
        var newMemory = Memory(
            id: memoryRef.documentID,
            userID: userID,
//            wineBottles: wineBottles,
            wineBottleIDs: wineBottleIDs,
            caption: caption,
            likedIDs: []
        )
        
        // Upload images to storage and get URLs
        for image in imageData {
            dispatchGroup.enter()
            let storageRef = Storage.storage().reference().child("memoryImages/\(UUID().uuidString).jpg")
            storageRef.putData(image, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image: \(error)")
                    return
                }
                
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error downloading image URL: \(error)")
                        return
                    }
                    
                    if let url = url {
                        imageURLs.append(url.absoluteString)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        // Create memory in database
        dispatchGroup.notify(queue: .main) { [self] in
            newMemory.images = imageURLs
            
            do {
                try memoryRef.setData(from: newMemory)
            } catch {
                print("Error saving memory to Firestore: \(error)")
                return
            }
            
            for var wineBottle in wineBottles {
                wineBottle.memoryIDs.append(newMemory.id!)
                let winebBottleRef = database.collection("Users").document(userID).collection("WineCollection").document(wineBottle.id!)
                do {
                    try winebBottleRef.setData(from: wineBottle, merge: true)
                } catch {
                    print("Error updating WineBottle: \(error)")
                }
            }
            
            completion(newMemory)
        }
    }        
    
    func fetchMemoriesForWineBottle(userID: String, memoryIDs: [String]) async -> [Memory] {
        guard !memoryIDs.isEmpty else { return [] }
        do {
            let query = database.collection("Users")
                        .document(userID)
                        .collection("Memories")
                        .order(by: "datePublished", descending: true)
                        .whereField(FieldPath.documentID(), in: memoryIDs)
            let docs = try await query.getDocuments()
            let memories = docs.documents.compactMap { document -> Memory? in
                try? document.data(as: Memory.self)
            }                       
            return memories
        } catch {
            print("Error fetching memories: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchMemoriesForUser(userID: String, limit: Int = 10, startAfterDoc: QueryDocumentSnapshot? = nil) async -> [Memory] {
        do {
            var query: Query
            query = database.collection("Users")
                    .document(userID)
                    .collection("Memories")
                    .order(by: "datePublished", descending: true)
                    .limit(to: limit)
            
            if let startAfterDoc = startAfterDoc {
                query = query.start(afterDocument: startAfterDoc)
            }
            
            let docs = try await query.getDocuments()
            
            if let lastDoc = docs.documents.last {
                paginationDocs[userID] = lastDoc
            }
            
            let memories = docs.documents.compactMap { document -> Memory? in
                try? document.data(as: Memory.self)
            }
            print("Fetched \(userID) Memories")
            return memories
        } catch {
            print("Error fetching memories: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchMemoriesForFeed(followingUserIDs: [String], resetPagination: Bool = false) async -> [Memory] {
        var allMemories: [Memory] = []
        
        if resetPagination {
            paginationDocs = [:]
        }
        
        for userID in followingUserIDs {
            let memories = await fetchMemoriesForUser(userID: userID, startAfterDoc: paginationDocs[userID] ?? nil)
            allMemories.append(contentsOf: memories)
        }
        
        // Sort all fetched memories by datePublished descending
        allMemories.sort { $0.datePublished > $1.datePublished } // Assuming datePublished is of type Date
        return allMemories
    }
    
    func isLiked(memory: Memory, userID: String) -> Bool {
        return memory.likedIDs?.contains(userID) ?? false
    }
    
    func toggleLikeForMemory(memory: Memory, userID: String) async {
        do {
            let memoryRef = database.collection("Users").document(memory.userID).collection("Memories").document(memory.id!)            
            if isLiked(memory: memory, userID: userID) {
                try await memoryRef.updateData([
                    "likedIDs": FieldValue.arrayRemove([userID])
                ])
                print("Removed Like from \(memory.id!)")
            } else {
                try await memoryRef.updateData([
                    "likedIDs": FieldValue.arrayUnion([userID])
                ])
                print("Added Like to \(memory.id!)")
            }
        } catch {
            print("Error Toggling Like: \(error.localizedDescription)")
        }
    }
    
    func deleteMemory(memory: Memory) async throws {
        guard let memoryID = memory.id else { return }
        // Delete Memory Images from Storage
        for imageURL in memory.images {
            guard let url = URL(string: imageURL) else { continue }
            let storageRef = Storage.storage().reference(forURL: url.absoluteString)
            do {
                try await storageRef.delete()
//                print("Deleted Image: \(imageURL)")
            } catch {
                print("Error Deleting Image: \(error.localizedDescription)")
                throw error
            }
        }
        // Delete Firestore Document
        do {
            try await self.database.collection("Users").document(memory.userID).collection("Memories").document(memoryID).delete()
            print("Memory Deleted Successfully")
        } catch {
            print("Error Deleting Memory: \(error.localizedDescription)")
            throw error
        }
    }
}
