//
//  StarRating.swift
//  Salute
//
//  Created by Shashaank Shankar on 8/8/24.
//

import SwiftUI

struct StarRating: View {
    let rating: Double

    var label = ""
    var maximumRating = 5
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    var offColor = Color.gray
    var onColor = Color.yellow

    var body: some View {
        HStack {
            if !label.isEmpty {
                Text(label)
            }

            ForEach(1..<maximumRating + 1, id: \.self) { number in
                image(for: number)
                    .foregroundColor(number > Int(rating) ? offColor : onColor)
            }
        }
    }
    
    private func image(for number: Int) -> Image {
        if number > Int(rating) {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
}
