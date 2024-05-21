//
//  PostViewModel.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/23/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    private let databaseReference = Firestore.firestore()
    
    // Fetch wine bottles from current user collection
    func fetchWineBottles(forUserID userID: String, completion: @escaping ([WineBottle]) -> Void) {
        databaseReference.collection("Users").document(userID).collection("WineCollection").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching wine bottles: \(error.localizedDescription)")
                completion([]) // Return an empty array in case of error
            } else {
                let wineBottles = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: WineBottle.self)
                } ?? []
                completion(wineBottles)
            }
        }
    }
}
