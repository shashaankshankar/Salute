//
//  Memory.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/24/24.
//

import Foundation
import FirebaseFirestoreSwift

struct Memory: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var userID: String
    var datePublished: Date = Date()
    
    // Wine Information (Link to the user's WineBottle)
    var wineBottleIDs: [String] = []
    
    var caption: String?
    var images: [String] = [] // Array of image URLs stored in Firebase Storage
    var likedIDs: [String]?
    
    static func == (lhs: Memory, rhs: Memory) -> Bool {
        return lhs.id == rhs.id && lhs.likedIDs == rhs.likedIDs
    }
}
