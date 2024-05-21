//
//  Wine.swift
//  Salute
//
//  Created by Shashaank Shankar on 6/7/24.
//

import Foundation
import FirebaseFirestoreSwift

// (Model for API Data)
struct WineAPI: Codable, Identifiable {
    var id: Int
    var winery: String?
    var wine: String?
    var rating: Rating?
    var location: String?
    var image: String?
    
    struct Rating: Codable {
        var average: String?
        var reviews: String?
    }
}
