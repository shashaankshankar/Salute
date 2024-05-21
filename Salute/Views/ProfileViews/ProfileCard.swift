//
//  ProfileCard.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/30/24.
//

import SwiftUI

struct ProfileCard: View {
    var user: User
    var showFollowButton: Bool = true
    
    var body: some View {
        HStack() {
            // Profile Image
            ZStack() {
                if let imageURL = user.profileImageURL, !imageURL.isEmpty {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image("DefaultProfilePicture")
                            .resizable()
                            .scaledToFill()
                    }
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .contentShape(Circle())
            .background(Circle().stroke(Color.gray, lineWidth: 2))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(user.name)
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                
                Text("@\(user.username)")
                    .font(.subheadline)
                    .fontWeight(.light)
            }
        }
    }
}
