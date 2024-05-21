//
//  AddBottleView.swift
//  Salute
//
//  Created by Shashaank Shankar on 6/6/24.
//

import SwiftUI
import PhotosUI
import SwiftUIIntrospect

struct AddBottleView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var apiViewModel = WineAPIViewModel()
    @StateObject private var viewModel = WineBottleViewModel()
    @State private var isLoading = false
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                modePicker
                if selectedSegment == 0 {
                    searchView
                } else {
                    ManualWineEntryView(viewModel: viewModel, presentationMode: _presentationMode)
                }
            }
            .navigationTitle("Add a Wine Bottle")
            .onAppear(perform: apiViewModel.fetchRedWines)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private var modePicker: some View {
        Picker("Mode", selection: $selectedSegment) {
            Text("Search").tag(0)
            Text("Manual Entry").tag(1)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var searchView: some View {
        List {
            ForEach(apiViewModel.filteredResults) { wine in
                Button(action: {
                    isLoading = true
                    viewModel.addWineAPIToCollection(wine, wineType: apiViewModel.currentWineType)
                    isLoading = false
                    presentationMode.wrappedValue.dismiss()
                }) {
                    WineCard(bottle: .api(wine)).padding()
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .searchable(text: $apiViewModel.searchText)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                FilterMenu(apiViewModel: apiViewModel)
            }
        }
    }
}

// MARK: - Manual Wine Entry View

struct ManualWineEntryView: View {
    @ObservedObject var viewModel: WineBottleViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var wineName = ""
    @State private var winery = ""
    @State private var wineType = "Red"
    @State private var description = ""
    @State private var useAIDescription = true
    @State private var tastingNotes = ""
    @State private var useAITastingNotes = true
    @State private var rating: Double = 1.0
    @State private var location = ""
    @State private var selectedPhoto: [PhotosPickerItem] = []
    @State private var imageData: Data?
    
    private let wineTypeOptions = ["Red", "White", "Sparkling", "Rose", "Dessert", "Port"]
    
    var body: some View {
        Form {
            wineDetailsSection
            descriptionSection
            tastingNotesSection
            ratingSection
            wineBottleImageSection
            addButton
        }
        .tint(wineBottle(wineType: wineType).wineTypeColor)
        .scrollDismissesKeyboard(.immediately)
        .onChange(of: useAIDescription) { if useAIDescription { description = "" } }
        .onChange(of: useAITastingNotes) { if useAITastingNotes { tastingNotes = "" } }
    }
    
    private var wineDetailsSection: some View {
        Section(header: Text("Wine Details")) {
            TextField("Wine Name", text: $wineName)
            TextField("Winery", text: $winery)
            VStack(alignment: .leading) {
                TextField("Location", text: $location)
                Text("Format: Region, Country").font(.caption).foregroundColor(.gray).opacity(0.6)
            }
            wineTypePicker
        }
    }
    
    private var wineTypePicker: some View {
        VStack(alignment: .leading) {
            Text("Wine Type").foregroundColor(.gray).opacity(0.6)
            segmentedPicker(choices: Array(wineTypeOptions[0...2]))
            segmentedPicker(choices: Array(wineTypeOptions[3...5]))
        }
    }
    
    private func segmentedPicker(choices: [String]) -> some View {
        Picker("Wine Type", selection: $wineType) {
            ForEach(choices, id: \.self) { type in
                Text(type)
            }
        }
        .pickerStyle(.segmented)
        .introspect(.picker(style: .segmented), on: .iOS(.v16, .v17)) { segmentedControl in
            segmentedControl.selectedSegmentTintColor = UIColor(wineBottle(wineType: wineType).wineTypeColor.opacity(0.75))
        }
    }
    
    private var descriptionSection: some View {
        Section(header: Text("Description")) {
            VStack(spacing: 0) {
                Toggle("Generate with AI", isOn: $useAIDescription)
                PoweredByGemini.frame(maxWidth: .infinity, alignment: .leading)
                if !useAIDescription {
                    TextEditor(text: $description).frame(height: 100)
                }
            }
            .listRowBackground(useAIDescription ? gradientBackground : nil)
        }
    }
    
    private var tastingNotesSection: some View {
        Section(header: Text("Tasting Notes")) {
            VStack(spacing: 0) {
                Toggle("Generate with AI", isOn: $useAITastingNotes)
                PoweredByGemini.frame(maxWidth: .infinity, alignment: .leading)
                if !useAITastingNotes {
                    TextEditor(text: $tastingNotes).frame(height: 100)
                }
            }
            .listRowBackground(useAITastingNotes ? gradientBackground : nil)
        }
    }
    
    private var ratingSection: some View {
        Section(header: Text("Rating")) {
            HStack {
                Text("\(String(format: "%.1f", rating))").font(.system(size: 24, weight: .bold))
                StarRating(rating: rating.rounded(.toNearestOrAwayFromZero))
            }.frame(maxWidth: .infinity, alignment: .center)
            Slider(value: $rating, in: 1...5, step: 0.1)
        }
    }
    
    private var wineBottleImageSection: some View {
        Section(header: Text("Wine Bottle Image")) {
            PhotosPicker(
                selection: $selectedPhoto,
                maxSelectionCount: 1,
                selectionBehavior: .default,
                matching: .images,
                preferredItemEncoding: .automatic
            ) {
                if let imageData = imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .shadow(radius: 1)
                } else {
                    Label("Select a Picture", systemImage: "photo.on.rectangle.angled")
                        .foregroundStyle(.blue)
                }
            }
            .onChange(of: selectedPhoto) { _,_ in
                loadSelectedPhoto()
            }
        }
    }
    
    private var addButton: some View {
        Button("Add to Collection") {
            viewModel.addManualWineToCollection(
                wineName: wineName,
                winery: winery,
                wineType: wineType,
                description: description,
                tastingNotes: tastingNotes,
                rating: String(format: "%.1f", rating),
                location: location,
                imageData: imageData
            )
            presentationMode.wrappedValue.dismiss()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowBackground(Color.clear)
        .font(.system(size: 20, weight: .semibold))
        .buttonStyle(.borderedProminent)
        .disabled(wineName.isEmpty || winery.isEmpty || location.isEmpty || imageData == nil)
    }
    
    private var gradientBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05), Color.pink.opacity(0.05)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ).overlay(
            RoundedRectangle(cornerRadius: 10, style: .circular).stroke(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5), Color.pink.opacity(0.5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ), lineWidth: 2)
        )
    }
    
    private func loadSelectedPhoto() {
        guard let item = selectedPhoto.first else { return }
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let data = data {
                    self.imageData = data
                }
            case .failure(let failure):
                print("Error: \(failure.localizedDescription)")
            }
        }
    }
    
    private func wineBottle(wineType: String) -> WineBottle {
        WineBottle(wineType: wineType)
    }
}

// MARK: - Filter Menu

struct FilterMenu: View {
    @State private var selectedFilter = "Reds" // Default filter
    let filters = ["Reds", "Whites", "Sparkling", "Rose", "Dessert", "Port"]
    @ObservedObject var apiViewModel: WineAPIViewModel

    var body: some View {
        Menu {
            ForEach(filters, id: \.self) { filter in
                Button(action: {
                    selectedFilter = filter
                    apiViewModel.fetchData(wineType: selectedFilter.lowercased())
                }) {
                    HStack {
                        Text(filter)
                        if selectedFilter == filter {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(selectedFilter)
                Image(systemName: "chevron.down")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
            )
        }
    }
}

// MARK: - Powered by Gemini

private var PoweredByGemini: some View {
    HStack(spacing: 0) {
        Text("Powered by ")
            .font(.system(size: 12, weight: .light))
        
        Image("Google_Gemini_logo")
            .resizable()
            .scaledToFit()
            .frame(height: 14)
            .padding(.bottom, 3)
    }
}

#Preview {
    AddBottleView()
}
