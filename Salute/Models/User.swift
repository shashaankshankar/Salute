//
//  User.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/19/24.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var uid: String
    var email: String
    var username: String
    var name: String
    var profileImageURL: String?
    var wineCount: Int = 0
    var followers: Int = 0
    var following: Int = 0
    var followingUserIDs: [String] = []
    
    // Compare User objects for equality
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid // Compare based on the uid
    }
}
