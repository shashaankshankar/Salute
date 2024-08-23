//
//  WineBottleViewModel.swift
//  Salute
//
//  Created by Shashaank Shankar on 6/5/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class WineBottleViewModel: ObservableObject {
    // @Published tells it to reload when our model (WineBottle) changes
    @Published var wineCollection = [WineBottle]()    
    @Published var wineTypeFilter: String = "All"
    @Published var sortOption: SortOption = .newest
    @Published var isLoading = false
    @Published var searchText: String = ""
    
    private lazy var databaseReference: CollectionReference? = {
        guard let user = Auth.auth().currentUser?.uid
        else { return nil }
        let ref = Firestore.firestore().collection("Users").document(user).collection("WineCollection")
        return ref
    } ()
    
    var filteredWineCollection: [WineBottle] {
        let filteredBySearch = wineCollection.filter {
            searchText.isEmpty || ($0.wine?.localizedCaseInsensitiveContains(searchText) ?? false) || ($0.winery?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
        let filteredByType = wineTypeFilter == "All" ? filteredBySearch : filteredBySearch.filter { $0.formattedWineType == wineTypeFilter }
        let filtered = searchText.isEmpty ? filteredByType : filteredBySearch
        switch sortOption {
        case .newest:
            return filtered.sorted { ($0.datePublished ?? Date.distantPast) > ($1.datePublished ?? Date.distantPast) }
        case .oldest:
            return filtered.sorted { ($0.datePublished ?? Date.distantPast) < ($1.datePublished ?? Date.distantPast) }
        case .wineryName:
            return filtered.sorted { ($0.winery ?? "").localizedCaseInsensitiveCompare($1.winery ?? "") == .orderedAscending }
        }
    }
    
    // Upload Image to Firebase Storage
    private func uploadImageToStorage(imageData: Data, completion: @escaping (URL?) -> Void) {
        let storageRef = Storage.storage().reference().child("wineImages/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error)")
                completion(nil)
                return
            }
            
            // Get download url
            storageRef.downloadURL { url, error in
                completion(url)
            }
        }
    }
    
    // Upload Wine Bottle to Firestore Database Collection
    private func postWineToFirestore(wineData: [String: Any]) {
        self.databaseReference?.addDocument(data: wineData) { error in
            if let error = error {
                print("Error adding wine to collection: \(error.localizedDescription)")
            } else {
                print("Wine added to collection successfully!")
                self.fetch()
                
                // Update wineCount in the User document
                Task {
                    if let currentUserID = Auth.auth().currentUser?.uid {
                        let userRef = Firestore.firestore().collection("Users").document(currentUserID)
                        try await userRef.updateData(["wineCount": FieldValue.increment(Int64(1))]) // Increment by 1
                    }
                }
            }
        }
        
    }
    
    // Add Wine API Bottle to Collection
    func addWineAPIToCollection(_ wine: WineAPI, wineType: String) {
        isLoading = true
        let genAIViewModel = GenerativeAIViewModel()
        let dispatchGroup = DispatchGroup()
        
        var wineData: [String: Any] = [
            "wineID": wine.id,
            "wine": wine.wine ?? "",
            "winery": wine.winery ?? "",
            "wineType": wineType,
            "ratingAverage": wine.rating?.average ?? "",
            "ratingReviews": wine.rating?.reviews ?? "",
            "location": wine.location ?? "",
            "image": wine.image ?? "",
            "datePublished": Date(),
            "memoryIDs": []
        ]
        
        // Gemini Generation Calls
        func generateWineDetails(completion: @escaping () -> Void) {
            // Generate description
            dispatchGroup.enter()
            genAIViewModel.generateWineAPIDescription(for: wine) { description, error in
                if let description = description {
                    wineData["description"] = description
                } else {
                    print("Error generating description: \(error?.localizedDescription ?? "Unknown error")")
                }
                dispatchGroup.leave()
            }
            
            // Generate tasting notes
            dispatchGroup.enter()
            genAIViewModel.generateWineAPITastingNotes(for: wine, wineType: wineType) { tastingNotes, error in
                if let tastingNotes = tastingNotes {
                    print("tasting Notes:", tastingNotes)
                    wineData["tastingNotes"] = tastingNotes
                } else {
                    print("Error generating tasting notes: \(error?.localizedDescription ?? "Unknown error")")
                }
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main, execute: completion) // Execute completion after both AI calls are done
        }
        
        generateWineDetails {
            self.postWineToFirestore(wineData: wineData)
            self.isLoading = false
        }
    }
    
    // Add Manual Entry Wine Bottle to Collection
    func addManualWineToCollection(wineName: String?, winery: String?, wineType: String?, description: String?, tastingNotes: String?, rating: String?, location: String?, imageData: Data?) {
        isLoading = true
        let genAIViewModel = GenerativeAIViewModel()
        let dispatchGroup = DispatchGroup()
        
        var wineData: [String: Any] = [
            "wine": wineName ?? "",
            "winery": winery ?? "",
            "wineType": wineType ?? "",
            "description": description ?? "",
            "tastingNotes": tastingNotes ?? "",
            "ratingAverage": rating ?? "",
            "location": location ?? "",
            "image": "",
            "datePublished": Date(),
            "memoryIDs": []
        ]
        
        // Gemini Generation Calls
        func generateWineDetails(completion: @escaping () -> Void) {
            
            if description == "" {
                // Generate description
                dispatchGroup.enter()
                genAIViewModel.generateWineBottleDescription(wineName: wineName!, winery: winery!, location: location!) { description, error in
                    if let description = description {
                        wineData["description"] = description
                    } else {
                        print("Error generating description: \(error?.localizedDescription ?? "Unknown error")")
                    }
                    dispatchGroup.leave()
                }
            }
            
            if tastingNotes == "" {
                // Generate tasting notes
                dispatchGroup.enter()
                genAIViewModel.generateWineBottleTastingNotes(wineName: wineName!, winery: winery!, location: location!, wineType: wineType!) { tastingNotes, error in
                    if let tastingNotes = tastingNotes {
                        wineData["tastingNotes"] = tastingNotes
                    } else {
                        print("Error generating tasting notes: \(error?.localizedDescription ?? "Unknown error")")
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main, execute: completion) // Execute completion after both AI calls are done
        }
        
        
        
        if let imageData = imageData {
            dispatchGroup.enter() // Start waiting for image upload
            
            // Upload the image to Firebase Storage
            uploadImageToStorage(imageData: imageData) { url in
                if let url = url {
                    wineData["image"] = url.absoluteString
                } else {
                    print("Error getting image download URL")
                }
                dispatchGroup.leave()
                
                generateWineDetails {
                    self.postWineToFirestore(wineData: wineData)
                    self.isLoading = false
                }
            }
        } else {
            // No image was provided, proceed without image upload
            generateWineDetails {
                self.postWineToFirestore(wineData: wineData)
                self.isLoading = false
            }
        }
    }
    
    // Fetch Data
    func fetch() {
        databaseReference?.addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No Documents")
                return
            }
            
            self.wineCollection = documents.compactMap { queryDocumentSnapshot -> WineBottle? in
                let wineBottle = try? queryDocumentSnapshot.data(as: WineBottle.self)
                return wineBottle
            }
        }
        print("Fetched Wine Collection")
    }
    
    func fetchUserCollection(userID: String) {
        let ref = Firestore.firestore().collection("Users").document(userID).collection("WineCollection")
        ref.addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No Documents")
                return
            }
            
            self.wineCollection = documents.compactMap { queryDocumentSnapshot -> WineBottle? in
                let wineBottle = try? queryDocumentSnapshot.data(as: WineBottle.self)
                return wineBottle
            }
        }
    }
    
    func fetchByID(userID: String, wineID: String, completion: @escaping (WineBottle?) -> Void) {
        let databaseReference = Firestore.firestore().collection("Users").document(userID).collection("WineCollection")
        databaseReference.document(wineID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching wine bottle: \(error.localizedDescription)")
                completion(nil)
            } else if let document = document, document.exists {
                do {
                    let wineBottle = try document.data(as: WineBottle.self)
                    completion(wineBottle)
                } catch {
                    print("Error decoding wine bottle: \(error)")
                    completion(nil)
                }
            } else {
                print("Wine bottle not found")
                completion(nil)
            }
        }
    }
    
    // Delete Data
    func delete(at indexSet: IndexSet) {
        indexSet.forEach { index in
            let wineBottle = filteredWineCollection[index]
            
            // Delete image from Storage if it exists
            if let imageURLString = wineBottle.image,
               imageURLString.hasPrefix("https://firebasestorage.googleapis.com") {
                
                let storageReference = Storage.storage().reference(forURL: imageURLString)
                storageReference.delete { error in
                    if let error = error {
                        print("Error deleting image: \(error.localizedDescription)")
                    } else {
                        print("Image deleted successfully")
                    }
                }
            }
            
            // Delete from Firestore
            databaseReference?.document(wineBottle.id ?? "").delete {
                error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Wine Bottle \(wineBottle.id ?? "") Deleted")
                }
            }
            
            // Update wineCount in the User document
            Task {
                if let currentUserID = Auth.auth().currentUser?.uid {
                    let userRef = Firestore.firestore().collection("Users").document(currentUserID)
                    try await userRef.updateData(["wineCount": FieldValue.increment(Int64(-1))]) // Decrement by 1
                }
            }
        }
    }        
}

enum SortOption: String, CaseIterable, Identifiable {
    case newest = "Newest"
    case oldest = "Oldest"
    case wineryName = "Alphabetical"
    
    var id: String { self.rawValue }
}
