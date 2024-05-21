//
//  MapView.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/8/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    let location: String
    @StateObject private var viewModel = MapViewModel()
            
    var body: some View {
        Map(position: $viewModel.cameraPosition, interactionModes: .zoom)
            .onAppear{
                viewModel.geocode(location: location)
            }            
    }
}

#Preview {
    MapView(location: "Atlanta, United States")
}
