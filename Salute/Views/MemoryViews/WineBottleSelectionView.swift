//
//  WineBottleSelectionView.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/24/24.
//

import SwiftUI

struct WineBottleSelectionView: View {
    @ObservedObject var wineViewModel = WineBottleViewModel()
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedWineBottles: [WineBottle]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 175))], spacing: 10) { // [GridItem(.flexible()), GridItem(.flexible())]
                    ForEach(wineViewModel.wineCollection) { wineBottle in
                        Button(action: {
                            addWineToSelection(wineBottle)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            WineCard(bottle: .collection(wineBottle), isVertical: true)
                                .blur(radius: selectedWineBottles.contains(where: { $0.id == wineBottle.id }) ? 0.5 : 0)
                                .overlay(
                                    selectedWineBottles.contains(where: { $0.id == wineBottle.id }) ?
                                    Color.white.opacity(0.3) : nil
                                )
                                .overlay(
                                    selectedWineBottles.contains(where: { $0.id == wineBottle.id }) ?
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.accentColor)
                                        .font(.largeTitle) : nil
                                )
                            // add .accentcolor border
                        }.buttonStyle(.plain)
                    }
                }.padding()
            }            
            .navigationTitle("Select Wines")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear(perform: wineViewModel.fetch)
        }
    }
    
    func addWineToSelection(_ wineBottle: WineBottle) {
        if selectedWineBottles.count < 5,
           !selectedWineBottles.contains(where: { $0.id == wineBottle.id }) {
            selectedWineBottles.append(wineBottle)
        }
    }
}
