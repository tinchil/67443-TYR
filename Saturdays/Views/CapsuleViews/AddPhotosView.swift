//
//  AddPhotosView.swift
//  Saturdays
//
//  Created by Tin on 12/5/25.
//

import SwiftUI
import PhotosUI

struct AddPhotosView: View {
    @ObservedObject var capsuleVM: CapsuleDetailsViewModel
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var loadedImages: [UIImage] = []
    @State private var showingPhotoPicker = false
    @State private var showSuccessView = false
    @Environment(\.dismiss) var dismiss

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // MARK: - HEADER
            Text("ADD PHOTOS")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255))
                .padding(.horizontal)
                .padding(.top, 20)

            // MARK: - DESCRIPTION
            Text("Choose the photos you want to add to your capsule.")
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255))
                .padding(.horizontal)

            // MARK: - PHOTO GRID
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<loadedImages.count, id: \.self) { index in
                        Image(uiImage: loadedImages[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .clipped()
                    }

                    // Add Photo Button
                    Button {
                        showingPhotoPicker = true
                    } label: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.systemGray5))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .padding(.horizontal)
            }

            // MARK: - DONE BUTTON
            Button {
                showSuccessView = true
            } label: {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.top, 40)
            .padding(.bottom, 30)

            Spacer()
        }
        .padding(.bottom, 160)   // ⭐ FIX: moves entire view above tab bar
        .background(Color.white)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showSuccessView) {
            CapsuleCreatedSuccessView()
        }
        .photosPicker(
            isPresented: $showingPhotoPicker,
            selection: $selectedPhotos,
            maxSelectionCount: 20,
            matching: .images
        )
        .onChange(of: selectedPhotos) { newItems in
            loadPhotos(from: newItems)
        }
    }

    // MARK: - Load Photos
    func loadPhotos(from items: [PhotosPickerItem]) {
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            if !loadedImages.contains(where: { $0.pngData() == image.pngData() }) {
                                loadedImages.append(image)
                            }
                        }
                    }
                case .failure(let error):
                    print("Error loading photo: \(error)")
                }
            }
        }
    }
}

#Preview {
    AddPhotosView(capsuleVM: CapsuleDetailsViewModel(capsule: CapsuleModel(type: .memory)))
}
