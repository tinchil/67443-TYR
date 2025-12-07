//
//  CapsuleDetailView.swift
//  Saturdays
//
//  Created by Tin 12/5/2025
//

import SwiftUI
import FirebaseAuth

struct CapsuleDetailView: View {
    let capsule: CapsuleModel

    @State private var showDeleteAlert = false
    @State private var showEditSheet = false
    @State private var isDeleting = false
    @State private var isSelectMode = false
    @State private var selectedPhotos: Set<String> = []
    @State private var showDeletePhotosAlert = false
    @State private var currentMediaURLs: [String] = []
    @Environment(\.dismiss) private var dismiss

    private let capsuleService = CapsuleService()
    private let storageService = StorageService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: - CAPSULE INFO SECTION
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(capsule.name.isEmpty ? "Untitled Capsule" : capsule.name)
                            .font(.title)
                            .fontWeight(.bold)

                        Spacer()

                        // Edit button
                        Button {
                            showEditSheet = true
                        } label: {
                            Image(systemName: "pencil.circle")
                                .font(.title2)
                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.8))
                        }
                    }

                    HStack {
                        Image(systemName: capsule.type == .memory ? "photo.fill" : "envelope.fill")
                        Text(capsule.type == .memory ? "Memory Capsule" : "Letter Capsule")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Image(systemName: "calendar")
                        Text("Created \(formattedDate(capsule.createdAt))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Image(systemName: "person.fill")
                        Text("Created by \(capsule.createdBy == Auth.auth().currentUser?.uid ?? "" ? "You" : "Friend")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                // MARK: - YOUR CONTRIBUTIONS (photos grouped by date)
                if !currentMediaURLs.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Your Contributions")
                                .font(.headline)

                            Spacer()

                            // Select/Cancel button
                            Button {
                                if isSelectMode {
                                    // Cancel selection
                                    isSelectMode = false
                                    selectedPhotos.removeAll()
                                } else {
                                    // Enter select mode
                                    isSelectMode = true
                                }
                            } label: {
                                Text(isSelectMode ? "Cancel" : "Select")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.8))
                            }
                        }
                        .padding(.horizontal)

                        // Delete selected button (only shown in select mode)
                        if isSelectMode && !selectedPhotos.isEmpty {
                            Button {
                                showDeletePhotosAlert = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete Selected (\(selectedPhotos.count))")
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }

                        // Photo grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8)
                        ], spacing: 8) {
                            ForEach(currentMediaURLs, id: \.self) { url in
                                ZStack(alignment: .topTrailing) {
                                    AsyncImage(url: URL(string: url)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                    }
                                    .frame(width: 110, height: 110)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedPhotos.contains(url) ? Color.blue : Color.clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        if isSelectMode {
                                            if selectedPhotos.contains(url) {
                                                selectedPhotos.remove(url)
                                            } else {
                                                selectedPhotos.insert(url)
                                            }
                                        }
                                    }

                                    // Checkmark for selected photos
                                    if isSelectMode && selectedPhotos.contains(url) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                            .background(Circle().fill(Color.white))
                                            .padding(6)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // MARK: - FINAL VIDEO (if exists)
                if let finalVideoURL = capsule.finalVideoURL {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Final Video")
                            .font(.headline)
                            .padding(.horizontal)

                        // TODO: Add video player
                        Text("Video URL: \(finalVideoURL)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            currentMediaURLs = capsule.mediaURLs
        }
        .alert("Delete Capsule?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteCapsule()
            }
        } message: {
            Text("This will permanently delete '\(capsule.name)' and all its photos. This action cannot be undone.")
        }
        .alert("Delete Photos?", isPresented: $showDeletePhotosAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSelectedPhotos()
            }
        } message: {
            Text("This will permanently delete \(selectedPhotos.count) photo(s) from this capsule.")
        }
        .sheet(isPresented: $showEditSheet) {
            EditCapsuleSheet(
                capsule: capsule,
                onDelete: {
                    showEditSheet = false
                    showDeleteAlert = true
                }
            )
        }
        .overlay {
            if isDeleting {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Deleting capsule...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(32)
                    .background(Color(white: 0.2))
                    .cornerRadius(16)
                }
            }
        }
    }

    // MARK: - DELETE CAPSULE
    private func deleteCapsule() {
        isDeleting = true

        // First delete all images from S3
        storageService.deleteImages(urls: capsule.mediaURLs) { success in
            // Then delete capsule from Firestore (even if S3 delete fails)
            capsuleService.deleteCapsule(capsuleID: capsule.id, groupID: capsule.groupID) { success in
                isDeleting = false
                if success {
                    dismiss()
                }
            }
        }
    }

    // MARK: - DELETE SELECTED PHOTOS
    private func deleteSelectedPhotos() {
        isDeleting = true

        // Delete selected photos from S3
        storageService.deleteImages(urls: Array(selectedPhotos)) { success in
            // Update capsule's mediaURLs in Firestore (remove deleted URLs)
            let updatedMediaURLs = currentMediaURLs.filter { !selectedPhotos.contains($0) }

            capsuleService.updateCapsuleMedia(capsuleID: capsule.id, mediaURLs: updatedMediaURLs) { success in
                isDeleting = false
                isSelectMode = false
                selectedPhotos.removeAll()

                // Update local state to reflect changes immediately
                currentMediaURLs = updatedMediaURLs
            }
        }
    }

    // MARK: - HELPER
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - EDIT CAPSULE SHEET
struct EditCapsuleSheet: View {
    let capsule: CapsuleModel
    let onDelete: () -> Void

    @State private var capsuleName: String
    @Environment(\.dismiss) private var dismiss

    private let capsuleService = CapsuleService()

    init(capsule: CapsuleModel, onDelete: @escaping () -> Void) {
        self.capsule = capsule
        self.onDelete = onDelete
        _capsuleName = State(initialValue: capsule.name)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Capsule Name") {
                    TextField("Enter capsule name", text: $capsuleName)
                }

                Section {
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Capsule")
                        }
                    }
                } footer: {
                    Text("This will permanently delete this capsule and all its photos.")
                        .font(.caption)
                }
            }
            .navigationTitle("Edit Capsule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateCapsuleName()
                    }
                    .disabled(capsuleName.isEmpty)
                }
            }
        }
    }

    private func updateCapsuleName() {
        capsuleService.updateCapsuleName(capsuleID: capsule.id, name: capsuleName) { success in
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        CapsuleDetailView(capsule: CapsuleModel(
            id: "preview",
            name: "Summer Memories",
            type: .memory,
            groupID: "group1",
            createdBy: "user1",
            createdAt: Date(),
            mediaURLs: [
                "https://picsum.photos/200",
                "https://picsum.photos/201",
                "https://picsum.photos/202"
            ],
            finalVideoURL: nil,
            coverPhotoURL: "https://picsum.photos/300"
        ))
    }
}
