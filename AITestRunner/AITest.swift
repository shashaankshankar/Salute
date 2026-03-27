//
//  AITest.swift
//  Salute
//
//  Created by Shashaank Shankar on 10/22/25.
//

import Foundation

@main
struct AITest {
    static func main() {
        let viewModel = GenerativeAIViewModel()
        let sampleWine = WineAPI(
            id: 0,
            winery: "Robert Mondavi",
            wine: "Cabernet Sauvignon",
            location: "Napa Valley, California"
        )

        let semaphore = DispatchSemaphore(value: 0)

        viewModel.generateWineAPIDescription(for: sampleWine) { result, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
            } else if let result = result {
                print("✅ AI Response:\n\(result)")
            }
            semaphore.signal()
        }

        // Wait until the async call finishes
        semaphore.wait()
    }
}
