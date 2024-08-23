//
//  CreateMemoryView.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/24/24.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct CreateMemoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var memoryViewModel = MemoryViewModel()
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var images: [UIImage] = [] // Array to store loaded UIImages
    @State private var selectedWineBottles: [WineBottle] = []
    @State private var caption: String = ""
    @State private var isWineSelectionPresented = false
    @State private var isLoading = false
    
    // Callback
    var onCreate: (Memory) -> ()
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    addPicturesSection
                    selectWinesSection
                    captionSection
                    createMemoryButton
                }
                .padding()
                .navigationTitle("Create Memory")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .sheet(isPresented: $isWineSelectionPresented) {
                    WineBottleSelectionView(selectedWineBottles: $selectedWineBottles)
                }
                .overlay(LoadingView(show: $isLoading))
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: selectedPhotos) { oldItems, newItems in
                loadSelectedPhotos(newItems)
            }
        }
    }
}

// MARK: - Subviews

extension CreateMemoryView {
    private var addPicturesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(title: "Add Your Pictures")
            
            if !images.isEmpty {
                imageCarousel
            }
            
            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: 10,
                selectionBehavior: .ordered,
                matching: .images,
                preferredItemEncoding: .automatic
            ) {
                Label("Select Pictures", systemImage: "photo.on.rectangle.angled")
            }
            .pickerStyleButtonStyle
            
            Text("Max 10 Images")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    private var imageCarousel: some View {
        TabView {
            ForEach(images, id: \.self) { image in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(5)
                    .padding(5)
            }
        }
        .frame(height: 325)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .interactive))
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.05))
        )
    }
    
    private var selectWinesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(title: "Select Your Wines")
            
            if !selectedWineBottles.isEmpty {
                wineBottleList
            }
            
            Button(action: { isWineSelectionPresented = true }) {
                Label("Add Bottle", systemImage: "plus.circle")
            }
            .pickerStyleButtonStyle
            
            Text("Max 5 Wines")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    private var wineBottleList: some View {
        LazyVStack {
            ForEach(selectedWineBottles.indices, id: \.self) { index in
                let bottle = selectedWineBottles[index]
                WineCard(bottle: .collection(bottle), isVertical: false, horizontalImageWidth: 30)
                    .overlay(alignment: .topTrailing) {
                        Button {
                            selectedWineBottles.remove(at: index)
                        } label: {
                            Image(systemName: "trash")
                                .fontWeight(.bold)
                                .tint(.red)
                        }.padding()
                    }
            }
        }
        .padding(.horizontal, 5)
    }
    
    private var captionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Caption", text: $caption, axis: .vertical)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
    
    private var createMemoryButton: some View {
        Button("Create Memory") {
            isLoading = true
            memoryViewModel.createMemory(
                userID: Auth.auth().currentUser!.uid,
                wineBottles: selectedWineBottles,
                caption: caption,
                imageData: images.compactMap { $0.jpegData(compressionQuality: 0.8) }
            ) { memory in
                onCreate(memory)
                isLoading = false
                presentationMode.wrappedValue.dismiss()
                print("Posted Memory \(memory.id!)")
            }
        }
        .padding()
        .font(.system(size: 20, weight: .semibold))
        .foregroundColor(.white)
        .background(Color.blue, in: RoundedRectangle(cornerRadius: 10))
        .frame(maxWidth: .infinity, alignment: .center)
        .disableWithOpacity(images.isEmpty || selectedWineBottles.isEmpty)
    }
}

// MARK: - Helper Functions

extension CreateMemoryView {
    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
            Spacer()
            if title == "Add Your Pictures" && !images.isEmpty {
                Button {
                    selectedPhotos = []
                } label: {
                    Text("Clear").fontWeight(.semibold)
                }.tint(.blue)
            }
        }
    }
    
    private func loadSelectedPhotos(_ newItems: [PhotosPickerItem]) {
        images = []
        Task {
            for newItem in newItems {
                if let data = try? await newItem.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                    images.append(image)
                }
            }
        }
    }
}

private extension View {
    var pickerStyleButtonStyle: some View {
        self
            .padding()
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                    .shadow(radius: 2)
            )
    }
}
