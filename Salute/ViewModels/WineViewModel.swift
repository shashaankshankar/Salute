//
//  WineViewModel.swift
//  Salute
//
//  Created by Shashaank Shankar on 6/7/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class WineViewModel: ObservableObject {
    @Published var wines = [Wine]()
    
    // Fetch Red Wines
    func fetchRedWines() {
        fetchData(from: "https://api.sampleapis.com/wines/reds")
    }
    
    // Fetch White Wines
    func fetchWhiteWines() {
        fetchData(from: "https://api.sampleapis.com/wines/whites")
    }
    
    // Fetch Sparkling Wines
    func fetchSparklingWines() {
        fetchData(from: "https://api.sampleapis.com/wines/sparkling")
    }
    
    // Fetch Rose Wines
    func fetchRoseWines() {
        fetchData(from: "https://api.sampleapis.com/wines/rose")
    }
    
    // Fetch Dessert Wines
    func fetchDessertWines() {
        fetchData(from: "https://api.sampleapis.com/wines/dessert")
    }
    
    // Fetch Port Wines
    func fetchPortWines() {
        fetchData(from: "https://api.sampleapis.com/wines/port")
    }
    
    private func fetchData(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            guard let data = data else { return }
            
            do {
                let decodedWines = try JSONDecoder().decode([Wine].self, from: data)
                DispatchQueue.main.async {
                    self.wines = decodedWines
                }
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
            }
        }.resume()
    }
}
