//
//  Post.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/22/24.
//

import Foundation
import FirebaseFirestoreSwift

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    
    var userID: String
    var publishedDate: Date = Date()
    var wineBottleID: String
    
    var caption: String?
    var rating: Double?
    var imageURL: String?
    
    var text: String    
    var imageReferenceID: String = ""
    var likedIDs: [String] = []
    
    var username: String
    var userUID: String
    var userProfileURL: URL
    
}
