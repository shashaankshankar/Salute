//
//  WineCard.swift
//  Salute
//
//  Created by Shashaank Shankar on 6/8/24.
//

import SwiftUI

enum WineSource {
    case api(WineAPI)
    case collection(WineBottle)
}

struct WineCard: View {
    let bottle: WineSource    
    var isVertical: Bool = false
    var horizontalImageWidth: CGFloat? = 50
    var verticalCardWidth: CGFloat? = 175
    var verticalImageHeight: CGFloat? = 200
    
    var body: some View {
        Group {
            if isVertical {
                verticalCard
            } else {
                horizontalCard
            }
        }
    }
    
    private var horizontalCard: some View {
        HStack(alignment: .top, spacing: 20) {
            AsyncImage(url: URL(string: image)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: horizontalImageWidth)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
            } placeholder: {
                Image("wineSilhouette")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: horizontalImageWidth)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
            }
                        
            VStack(alignment: .leading, spacing: 5) {
                Text(winery)
                    .font(.system(size: 20, weight: .bold))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(wine)
                    .font(.system(size: 16))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .truncationMode(.tail)
                
                if case .collection(_) = bottle {
                    Spacer()
                    Text(wineType)
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(wineTypeColor)
                                .shadow(radius: 0.5)
                        )
                }
            }
        }
        .padding(applyHCardStyle ? 15 : 0)
        .frame(maxWidth: applyHCardStyle ? .infinity : nil, alignment: .leading)
        .background(
            applyHCardStyle ? AnyView(
                RoundedRectangle(cornerRadius: 10)
                    .fill(wineTypeColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 3)
                            .blur(radius: 2)
                    )
            ) : nil
        )
    }
    
    private var verticalCard: some View {
        VStack(alignment: .center, spacing: 10) {
            AsyncImage(url: URL(string: image)) { image in
                image
                    .resizable()
                    .scaledToFit()
//                    .frame(width: verticalCardWidth, height: verticalImageHeight)
                    .frame(maxHeight: verticalImageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
            } placeholder: {
                Image("wineSilhouette")
                    .resizable()
                    .scaledToFit()
//                    .frame(width: verticalCardWidth, height: verticalImageHeight)
                    .frame(maxHeight: verticalImageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading) {
                Text(winery)
                    .font(.system(size: 20, weight: .semibold))
                    .lineLimit(3)
                    .truncationMode(.tail)
                Text(wine)
                    .font(.system(size: 16))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .truncationMode(.tail)
                
                if case .collection(_) = bottle {
                    Text(wineType)
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(wineTypeColor)
                                .shadow(radius: 0.5)
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(width: verticalCardWidth, height: 300)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(wineTypeColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 5)
                        .blur(radius: 2)
                )
        )
    }
    
    
    private var image: String {
        switch bottle {
        case .api(let wineAPI): return wineAPI.image ?? ""
        case .collection(let wineBottle): return wineBottle.image ?? ""
        }
    }

    private var winery: String {
        switch bottle {
        case .api(let wineAPI): return wineAPI.winery ?? ""
        case .collection(let wineBottle): return wineBottle.winery ?? ""
        }
    }

    private var wine: String {
        switch bottle {
        case .api(let wineAPI): return wineAPI.wine ?? ""
        case .collection(let wineBottle): return wineBottle.wine ?? ""
        }
    }
    
    private var wineType: String {
        switch bottle {
        case .api: return ""
        case .collection(let wineBottle): return wineBottle.formattedWineType
        }
    }
    
    private var wineTypeColor: Color {
        switch bottle {
        case .api: return .clear
        case .collection(let wineBottle): return wineBottle.wineTypeColor
        }
    }
    
    private var applyHCardStyle: Bool {
        if case .collection(_) = bottle {
            return true
        }
        return false
    }
}
