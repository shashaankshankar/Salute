//
//  PostCard.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/23/24.
//

import SwiftUI

struct PostCard: View {
    @State var image: String = ""
    
    var body: some View {
        HStack() {
            AsyncImage(url: URL(string: image)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
            } placeholder: {
//                ProgressView()
                Image("wineSilhouette")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
            }
            
            
        }
    }
}

#Preview {
    PostCard()
}
