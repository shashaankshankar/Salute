//
//  MapViewModel.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/8/24.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

class MapViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Published var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.75, longitudeDelta: 0.75)
    ))
    
    func geocode(location: String) {
        print("Searching Location: \(location)")
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { [weak self] placemarks, error in
            if let error = error as? CLError {
                print("Geocoding error: \(error.localizedDescription)")
                switch error.code {
                case .geocodeFoundNoResult:
                    // Handle case where no result was found
                    print("No location found for: \(location)")
                    self?.updateRegionWithDefaultCountry(location: location)
                default:
                    // Handle other errors if needed
                    print("Other geocoding error: \(error.localizedDescription)")
                }
                return
            }
            
            if let coordinate = placemarks?.first?.location?.coordinate {
                DispatchQueue.main.async {
                    self?.updateRegion(center: coordinate)
                }
            }
        }
    }
    
    private func updateRegion(center: CLLocationCoordinate2D) {
        self.cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.75, longitudeDelta: 0.75)
        ))
    }
    
    private func updateRegionWithDefaultCountry(location: String) {
        // Assuming location is in format "City, Country"
        let components = location.components(separatedBy: ", ")
        guard components.count == 2 else {
            print("Invalid location format: \(location)")
            return
        }
        
        let country = components[1]
        
        // Geocode the country to get its coordinates
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(country) { [weak self] placemarks, error in
            if let coordinate = placemarks?.first?.location?.coordinate {
                DispatchQueue.main.async {
                    self?.updateRegion(center: coordinate)
                }
            } else {
                print("Failed to geocode country: \(country)")
                // Fallback to a default location (e.g., center of the country or another default)
                let defaultCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
                DispatchQueue.main.async {
                    self?.updateRegion(center: defaultCoordinate)
                }
            }
        }
    }
}
