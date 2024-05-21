//
//  WineAPIViewModel.swift
//  Salute
//
//  https://sampleapis.com/api-list/wines
//
//  Created by Shashaank Shankar on 6/7/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class WineAPIViewModel: ObservableObject {
    @Published var apiWines = [WineAPI]()
    @Published var searchText: String = "" 
    @Published var currentWineType: String = "Reds"
    var filteredResults: [WineAPI] {
        guard !searchText.isEmpty else { return Array(apiWines.prefix(100)) }
        let test = apiWines.filter { wine in
            (wine.wine?.localizedCaseInsensitiveContains(searchText) ?? false) || (wine.winery?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
        return test
    }
    
    // Fetch Red Wines
    func fetchRedWines() {
        fetchData(wineType: "reds")
        print("Fetched Red Wines")
    }
    
    // Fetch White Wines
    func fetchWhiteWines() {
        fetchData(wineType: "whites")
        print("Fetched White Wines")
    }
    
    // Fetch Sparkling Wines
    func fetchSparklingWines() {
        fetchData(wineType: "sparkling")
        print("Fetched Sparkling Wines")
    }
    
    // Fetch Rose Wines
    func fetchRoseWines() {
        fetchData(wineType: "rose")
        print("Fetched Rose Wines")
    }
    
    // Fetch Dessert Wines
    func fetchDessertWines() {
        fetchData(wineType: "dessert")
        print("Fetched Dessert Wines")
    }
    
    // Fetch Port Wines
    func fetchPortWines() {
        fetchData(wineType: "port")
        print("Fetched Port Wines")
    }
    
    // Fetch all Wines
    func fetchAllWines() {
        fetchRedWines()
        fetchWhiteWines()
        fetchSparklingWines()
        fetchRoseWines()
        fetchDessertWines()
        fetchPortWines()
    }
    
    // Fetch data from api endpoint and update apiWines list
    func fetchData(wineType: String) {
        guard let url = URL(string: "https://api.sampleapis.com/wines/\(wineType)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            guard let data = data else { return }
            
            do {
                let decodedWines = try JSONDecoder().decode([WineAPI].self, from: data)
                DispatchQueue.main.async {
                    self.apiWines = decodedWines
                    self.currentWineType = wineType
                }
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
            }
        }.resume()
                
        print("Fetched \(wineType.uppercased()) Wines")
    }
    
    // Directly fetch wines from the API and return list
    func fetchWinesFromAPI(wineType: String) async -> [WineAPI] {
        guard let url = URL(string: "https://api.sampleapis.com/wines/\(wineType)") else { return [] }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let wines = try JSONDecoder().decode([WineAPI].self, from: data)
            return wines
        } catch {
            print("Error fetching wines from API: \(error.localizedDescription)")
            return []
        }
    }    
}

