//
//  WineBottle.swift
//  Salute
//
//  Created by Shashaank Shankar on 6/5/24.
//

import Foundation
import FirebaseFirestoreSwift
import SwiftUI

// (Model for User Collection)
struct WineBottle: Codable, Identifiable {
//  @DocumentID maps the document with the identifier in Firebase
    @DocumentID var id: String?
    var wineID: Int?   // Link to the API wine ID
    var wine: String?
    var winery: String?
    var wineType: String?
    var description: String?
    var tastingNotes: String?
    var ratingAverage: String?
    var ratingReviews: String?
    var location: String?
    var image: String?
    @ServerTimestamp var datePublished: Date?
    var memoryIDs: [String] = []
    
    var formattedWineType: String {
        guard var wineType = wineType else { return "[Wine Type]" }
        wineType = wineType.capitalized
        
        if wineType == "Reds" {
            wineType = "Red"
        } else if wineType == "Whites" {
            wineType = "White"
        }
        
        return wineType
    }
    
    var formattedRatingAverage: String {
        ratingAverage?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "") ?? ""
    }
    
    var formattedRatingReviews: String {
        if let ratingReviews = ratingReviews, let number = ratingReviews.split(separator: " ").first {
            return "\(number) Ratings"
        } else {
            return ""
        }
    }
    
    var formattedLocation: String {
        let components = location?.components(separatedBy: "\n·\n") ?? []
        if components.count == 2 {
          return "\(components[1]), \(components[0])"
        } else {
          return location ?? ""
        }
    }
    
    var wineTypeColor: Color {
        switch formattedWineType.lowercased() {
        case "red": return .red.opacity(0.75)
        case "white": return Color(red: 0.91, green: 0.60, blue: 0.25, opacity: 0.75) // honey
        case "sparkling": return Color(red: 0.87, green: 0.75, blue: 0.62, opacity: 0.75) // opulence champagne
        case "rose": return .pink.opacity(0.5)
        case "dessert": return .blue.opacity(0.6)
        case "port": return .purple.opacity(0.6)
        default: return .gray.opacity(0.2)
        }
    }
}
