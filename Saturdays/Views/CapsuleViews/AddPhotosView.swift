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
    var existingCapsule: CapsuleModel? = nil  // If provided, we're adding to an existing capsule
    var onPhotosAdded: (([String]) -> Void)? = nil  // Callback when photos are added to existing capsule

    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var loadedImages: [UIImage] = []
    @State private var showingPhotoPicker = false
    @State private var showSuccessView = false
    @State private var isUploading = false
    @Environment(\.dismiss) var dismiss

    private let storageService = StorageService()
    private let capsuleService = CapsuleService()

    private var isAddingToExisting: Bool {
        existingCapsule != nil
    }

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // MARK: - HEADER
            Text(isAddingToExisting ? "ADD MORE PHOTOS" : "ADD PHOTOS")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255))
                .padding(.horizontal)
                .padding(.top, 20)

            // MARK: - DESCRIPTION
            Text(isAddingToExisting
                ? "Choose additional photos to add to this capsule."
                : "Choose the photos you want to add to your capsule.")
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
                createCapsule()
            } label: {
                if isUploading {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Uploading...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(12)
                } else {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(loadedImages.isEmpty ? Color.gray : Color.black)
                        .cornerRadius(12)
                }
            }
            .disabled(loadedImages.isEmpty || isUploading)
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

    // MARK: - Create Capsule OR Add Photos to Existing
    func createCapsule() {
        guard !loadedImages.isEmpty else { return }

        isUploading = true

        // If adding to existing capsule, skip creation step
        if let existing = existingCapsule {
            print("📸 Adding \(loadedImages.count) photos to existing capsule: \(existing.id)")

            // Upload images to S3
            storageService.uploadImages(loadedImages, capsuleID: existing.id) { uploadedURLs in
                guard !uploadedURLs.isEmpty else {
                    print("❌ No images uploaded successfully")
                    isUploading = false
                    return
                }

                // Combine with existing media URLs
                let updatedURLs = existing.mediaURLs + uploadedURLs

                // Update capsule with combined media URLs
                capsuleService.updateCapsuleMedia(capsuleID: existing.id, mediaURLs: updatedURLs) { success in
                    isUploading = false

                    if success {
                        print("✅ Added \(uploadedURLs.count) new photos to capsule")

                        // Call the callback to notify parent view
                        onPhotosAdded?(updatedURLs)

                        dismiss()
                    } else {
                        print("❌ Failed to update capsule media")
                    }
                }
            }
            return
        }

        // Otherwise, create new capsule
        guard let groupID = capsuleVM.selectedGroupID else {
            print("❌ No group selected")
            isUploading = false
            return
        }

        // First, create the capsule in Firestore (without media URLs yet)
        capsuleService.createCapsule(
            name: capsuleVM.capsule.name,
            type: capsuleVM.capsule.type,
            groupID: groupID,
            mediaURLs: [],
            revealDate: capsuleVM.capsule.revealDate,
            minContribution: capsuleVM.capsule.minContribution
        ) { capsuleID in
            guard let capsuleID = capsuleID else {
                print("❌ Failed to create capsule")
                isUploading = false
                return
            }

            print("✅ Capsule created with ID: \(capsuleID)")

            // Now upload images to Firebase Storage
            storageService.uploadImages(loadedImages, capsuleID: capsuleID) { uploadedURLs in
                guard !uploadedURLs.isEmpty else {
                    print("❌ No images uploaded successfully")
                    isUploading = false
                    return
                }

                // Update capsule with uploaded media URLs
                capsuleService.updateCapsuleMedia(capsuleID: capsuleID, mediaURLs: uploadedURLs) { success in
                    isUploading = false

                    if success {
                        print("✅ Capsule media updated with \(uploadedURLs.count) photos")

                        // Log activity
                        ActivityService.shared.logPhotoAdded(
                            capsuleID: capsuleID,
                            capsuleName: capsuleVM.capsule.name,
                            photoCount: uploadedURLs.count
                        )

                        showSuccessView = true
                    } else {
                        print("❌ Failed to update capsule media")
                    }
                }
            }
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
