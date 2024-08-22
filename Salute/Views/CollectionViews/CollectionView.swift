//
//  CollectionView.swift
//  Salute
//
//  Created by Shashaank Shankar on 6/6/24.
//

import SwiftUI
import FirebaseFirestoreSwift

struct CollectionView: View {
    @State private var showSheet: Bool = false
    @State private var isListView: Bool = false
    @EnvironmentObject private var authModel: AuthViewModel
    @ObservedObject private var wineViewModel = WineBottleViewModel()
    @ObservedObject private var wineAPI = WineAPIViewModel() 
    
    var body: some View {
        NavigationStack {
            GridView()
            .refreshable {
                wineViewModel.fetch()
            }
            .navigationTitle("Wine Collection")
            .searchable(text: $wineViewModel.searchText)
            .onAppear(perform: wineViewModel.fetch)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {                    
                    Menu("Filter/Sort", systemImage: "arrow.up.arrow.down.circle") {
                        Menu("Filter") {
                            Picker("Filter by Type", selection: $wineViewModel.wineTypeFilter) {
                                Text("All").tag("All")
                                Text("Red").tag("Red")
                                Text("White").tag("White")
                                Text("Sparkling").tag("Sparkling")
                                Text("Rose").tag("Rose")
                                Text("Dessert").tag("Dessert")
                                Text("Port").tag("Port")
                            }
                        }
                        Menu("Sort") {
                            Picker("Sort by", selection: $wineViewModel.sortOption) {
                                ForEach(SortOption.allCases) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSheet.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .imageScale(.large)
                    }
                    .sheet(isPresented: $showSheet) {
                        AddBottleView()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func GridView() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 175))], spacing: 10) { // [GridItem(.flexible()), GridItem(.flexible())]
                ForEach(wineViewModel.filteredWineCollection.indices, id: \.self) { index in
                    let wineBottle = wineViewModel.filteredWineCollection[index]
                    if let userID = authModel.currentUser?.uid {
                        NavigationLink(destination: 
                            BottleDetailView(userID: userID, wineBottle: wineBottle)
//                            .navigationTransitionStyle(.zoom(sourceID: wineBottle.id, in: wineViewModel.filteredWineCollection))
                        ) {
                            WineCard(bottle: .collection(wineBottle), isVertical: true)
                                .padding(.horizontal)
                                .padding(.vertical, 5)                                
                        }
                        .buttonStyle(.plain)
                        .contextMenu { // Add context menu to each NavigationLink
                            Button("Delete", role: .destructive) {
                                wineViewModel.delete(at: IndexSet(integer: index))
                            }
                        }
//                        .matchedTransitionSource(id: wineBottle.id, in: wineViewModel.filteredWineCollection)
                    }
                }
            }.padding()
        }
    }
}

#Preview {
    CollectionView()
}
