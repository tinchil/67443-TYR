//
//  AddPhotosView.swift
//  Saturdays
//
//  Created by Claude Code
//

import SwiftUI
import PhotosUI

struct AddPhotosView: View {
    @ObservedObject var viewModel: GroupCreationViewModel
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var navigateToConfirmation = false
    @State private var showImagePicker = false

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Add Photos")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Choose photos to add to this capsule")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 20)

            // Photos Grid or Empty State
            if viewModel.selectedPhotos.isEmpty {
                Spacer()

                VStack(spacing: 30) {
                    // Camera Icon
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 120, height: 120)

                        Image(systemName: "camera.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                    }

                    Text("No photos selected")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    // Action Buttons
                    VStack(spacing: 12) {
                        PhotosPicker(
                            selection: $selectedItems,
                            matching: .images
                        ) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                Text("Choose from Library")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }

                        Button(action: {
                            showImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "camera")
                                Text("Take Photo")
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 30)
                }

                Spacer()
            } else {
                // Photos Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(Array(viewModel.selectedPhotos.enumerated()), id: \.offset) { index, photo in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: photo)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(8)

                                // Remove button
                                Button(action: {
                                    removePhoto(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.red))
                                        .font(.title3)
                                }
                                .offset(x: 8, y: -8)
                            }
                        }

                        // Add more button
                        PhotosPicker(
                            selection: $selectedItems,
                            matching: .images
                        ) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 100, height: 100)

                                Image(systemName: "plus")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                }

                // Next Button
                Button(action: {
                    navigateToConfirmation = true
                }) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding()
            }
        }
        .navigationTitle("Add Photos")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedItems) { newItems in
            Task {
                await loadPhotos(from: newItems)
            }
        }
        .navigationDestination(isPresented: $navigateToConfirmation) {
            PhotoConfirmationView(viewModel: viewModel)
        }
    }

    private func loadPhotos(from items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    viewModel.selectedPhotos.append(image)
                }
            }
        }
    }

    private func removePhoto(at index: Int) {
        viewModel.selectedPhotos.remove(at: index)
    }
}

#Preview {
    NavigationStack {
        AddPhotosView(viewModel: GroupCreationViewModel())
    }
}
