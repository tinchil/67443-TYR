//
//  CapsuleDetailView.swift
//  Saturdays
//

import SwiftUI
import FirebaseAuth
import AVKit

struct CapsuleDetailView: View {
    @State var capsule: CapsuleModel

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

    private var isUnlocked: Bool {
        guard let revealDate = capsule.revealDate else { return true }
        return Date() >= revealDate
    }

    // ----------------------------------------------------------
    // MARK: - BODY
    // ----------------------------------------------------------

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    capsuleInfoSection

                    Divider().padding(.horizontal)

                    // Show photos for memory capsules, letters for letter capsules
                    if capsule.type == .memory {
                        if !currentMediaURLs.isEmpty {
                            contributionSection
                        }
                    } else {
                        lettersSection
                    }

                    Divider().padding(.horizontal)

                    finalVideoSection
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                print("🟢 CapsuleDetailView.onAppear called")
                handleAppear()
            }
            .alert("Delete Capsule?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) { deleteCapsule() }
            }
            .alert("Delete Photos?", isPresented: $showDeletePhotosAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) { deleteSelectedPhotos() }
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
            .overlay { if isDeleting { deletingOverlay } }
        }
    }

    // ----------------------------------------------------------
    // MARK: - INFO SECTION
    // ----------------------------------------------------------

    private var capsuleInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text(capsule.name.isEmpty ? "Untitled Capsule" : capsule.name)
                    .font(.title)
                    .bold()

                Spacer()

                Button { showEditSheet = true } label: {
                    Image(systemName: "pencil.circle")
                        .font(.title2)
                        .foregroundColor(.indigo)
                }
            }

            Label(capsule.type == .memory ? "Memory Capsule" : "Letter Capsule",
                  systemImage: capsule.type == .memory ? "photo.fill" : "envelope.fill")
            .foregroundColor(.gray)

            Label("Created \(formattedDate(capsule.createdAt))", systemImage: "calendar")
                .foregroundColor(.gray)

            Label("Created by \(capsule.createdBy == Auth.auth().currentUser?.uid ? "You" : "Friend")",
                  systemImage: "person.fill")
            .foregroundColor(.gray)

            VStack(alignment: .leading) {
                if let date = capsule.revealDate {
                    Label("Reveals on \(formattedDate(date))", systemImage: "clock")
                        .foregroundColor(.gray)
                }
                // Only show minimum contributions for memory capsules
                if capsule.type == .memory {
                    Label("Minimum contributions: \(capsule.minContribution ?? 0)", systemImage: "person.3")
                        .foregroundColor(.gray)
                }
            }
            .font(.subheadline)
        }
        .padding(.horizontal)
    }

    // ----------------------------------------------------------
    // MARK: - CONTRIBUTION SECTION
    // ----------------------------------------------------------

    private var contributionSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                Text("Your Contributions")
                    .font(.headline)

                Spacer()

                Button {
                    isSelectMode.toggle()
                    if !isSelectMode { selectedPhotos.removeAll() }
                } label: {
                    Text(isSelectMode ? "Cancel" : "Select")
                        .foregroundColor(.indigo)
                }
            }
            .padding(.horizontal)

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
                    .padding(10)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(currentMediaURLs, id: \.self) { url in
                    ZStack(alignment: .topTrailing) {
                        AsyncImage(url: URL(string: url)) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            Rectangle().fill(Color.gray.opacity(0.2))
                        }
                        .frame(width: 110, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedPhotos.contains(url) ? .blue : .clear, lineWidth: 3)
                        )
                        .onTapGesture {
                            guard isSelectMode else { return }
                            if selectedPhotos.contains(url) { selectedPhotos.remove(url) }
                            else { selectedPhotos.insert(url) }
                        }

                        if isSelectMode && selectedPhotos.contains(url) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .padding(6)
                        }
                    }
                }
            }
            .padding(.horizontal)

            // Add Photos Button
            NavigationLink(destination: AddPhotosView(
                capsuleVM: CapsuleDetailsViewModel(capsule: capsule),
                existingCapsule: capsule,
                onPhotosAdded: { updatedURLs in
                    capsule.mediaURLs = updatedURLs
                    currentMediaURLs = updatedURLs
                }
            )) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Photos")
                }
                .foregroundColor(.indigo)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.indigo.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }

    // ----------------------------------------------------------
    // MARK: - LETTERS SECTION
    // ----------------------------------------------------------

    private var lettersSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Letters")
                .font(.headline)
                .padding(.horizontal)

            if capsule.letters.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "envelope")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)

                    Text("No letters yet")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("Be the first to write a letter to the group")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(capsule.letters) { letter in
                            LetterCardView(letter: letter)
                        }
                    }
                }
                .frame(maxHeight: 400)
                .padding(.horizontal)
            }

            // Add Letter Button
            NavigationLink(destination: AddLettersView(
                capsuleVM: CapsuleDetailsViewModel(capsule: capsule),
                existingCapsule: capsule,
                onLetterAdded: { updatedLetters in
                    capsule.letters = updatedLetters
                }
            )) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Letter")
                }
                .foregroundColor(.indigo)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.indigo.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }

    // ----------------------------------------------------------
    // MARK: - FINAL VIDEO SECTION
    // ----------------------------------------------------------

    private var finalVideoSection: some View {
        Group {
            // Check if capsule is locked
            if !isUnlocked {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Final Video")
                        .font(.headline)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)

                        if let revealDate = capsule.revealDate {
                            Text("Locked until \(formattedDate(revealDate))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Text("The final video will be available after the reveal date")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            } else if let finalString = capsule.finalVideoURL,
                      let url = URL(string: finalString) {

                VStack(alignment: .leading, spacing: 12) {

                    Text("Final Video")
                        .font(.headline)
                        .padding(.horizontal)

                    NavigationLink(
                        destination: VideoPlayerView(
                            url: url,
                            capsuleTitle: capsule.name,
                            capsuleDescription: nil,
                            revealDate: capsule.revealDate
                        )
                        .onAppear {
                            print("▶️ VideoPlayerView.onAppear - Navigation worked")
                            print("🎥 Video URL: \(url.absoluteString)")
                        }
                    ) {
                        Text("Watch Final Video")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        print("🔴 NavigationLink tapped - URL: \(url.absoluteString)")
                    })
                }

            } else {
                Text("Generating your video…")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
        }
    }

    // ----------------------------------------------------------
    // MARK: - APPEAR / LOGIC
    // ----------------------------------------------------------

    private func handleAppear() {
        print("🟢 handleAppear() called")
        print("   Before assignment → currentMediaURLs:", currentMediaURLs)
        currentMediaURLs = capsule.mediaURLs
        print("   After assignment → currentMediaURLs:", currentMediaURLs)

        generateFinalVideo()
    }

    // ----------------------------------------------------------
    // MARK: - GENERATE VIDEO
    // ----------------------------------------------------------

    private func generateFinalVideo() {
        print("🎬 generateFinalVideo() CALLED")
        print("   currentMediaURLs.count: \(currentMediaURLs.count)")
        print("   capsule.finalVideoURL: \(capsule.finalVideoURL ?? "nil")")

        makePhotoItems(from: currentMediaURLs) { items in
            print("📸 makePhotoItems completed with \(items.count) items")

            VideoCreator.createVideo(from: items) { localURL in
                print("🎥 VideoCreator.createVideo completed")
                print("   localURL: \(localURL?.absoluteString ?? "nil")")
                guard let localURL else {
                    print("❌ Failed to create video")
                    return
                }

                print("✅ Video created locally at: \(localURL)")

                storageService.uploadVideo(localURL, capsuleID: capsule.id) { remoteURL in
                    guard let remoteURL else {
                        print("❌ Failed to upload video to S3")
                        return
                    }

                    print("✅ Video uploaded to S3: \(remoteURL)")

                    capsuleService.updateFinalVideoURL(
                        capsuleID: capsule.id,
                        finalVideoURL: remoteURL
                    ) { success in
                        if success {
                            DispatchQueue.main.async {
                                print("✅ FINAL VIDEO URL SAVED TO FIRESTORE:", remoteURL)
                                capsule.finalVideoURL = remoteURL
                            }
                        }
                    }

                    try? FileManager.default.removeItem(at: localURL)
                }
            }
        }
    }

    // ----------------------------------------------------------
    // MARK: - PHOTO LOADER
    // ----------------------------------------------------------

    private func makePhotoItems(from urls: [String], completion: @escaping ([PhotoItem]) -> Void) {
        print("📸 makePhotoItems() STARTED - downloading \(urls.count) images")

        DispatchQueue.global(qos: .userInitiated).async {
            let items = urls.compactMap { urlString -> PhotoItem? in
                print("   ⬇️ Downloading: \(urlString)")
                guard let url = URL(string: urlString),
                      let data = try? Data(contentsOf: url),
                      let img = UIImage(data: data)
                else {
                    print("   ❌ Failed to download: \(urlString)")
                    return nil
                }
                print("   ✅ Downloaded: \(urlString)")
                return PhotoItem(image: img, location: nil, timestamp: Date())
            }
            DispatchQueue.main.async {
                print("📸 makePhotoItems() COMPLETED")
                completion(items)
            }
        }
    }

    // ----------------------------------------------------------
    // MARK: - DELETE
    // ----------------------------------------------------------

    private func deleteCapsule() {
        isDeleting = true
        storageService.deleteImages(urls: capsule.mediaURLs) { _ in
            capsuleService.deleteCapsule(capsuleID: capsule.id, groupID: capsule.groupID) { success in
                isDeleting = false
                if success { dismiss() }
            }
        }
    }

    private func deleteSelectedPhotos() {
        isDeleting = true
        storageService.deleteImages(urls: Array(selectedPhotos)) { _ in
            let updated = currentMediaURLs.filter { !selectedPhotos.contains($0) }
            capsuleService.updateCapsuleMedia(capsuleID: capsule.id, mediaURLs: updated) { _ in
                currentMediaURLs = updated
                isDeleting = false
                isSelectMode = false
                selectedPhotos.removeAll()
            }
        }
    }

    // ----------------------------------------------------------
    // MARK: - HELPERS
    // ----------------------------------------------------------

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }

    private var deletingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack {
                ProgressView().scaleEffect(1.4)
                Text("Deleting capsule...")
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(Color(white: 0.15))
            .cornerRadius(12)
        }
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
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { updateCapsuleName() }
                        .disabled(capsuleName.isEmpty)
                }
            }
        }
    }

    private func updateCapsuleName() {
        capsuleService.updateCapsuleName(capsuleID: capsule.id, name: capsuleName) { success in
            if success { dismiss() }
        }
    }
}

// MARK: - LETTER CARD VIEW
struct LetterCardView: View {
    let letter: LetterModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(letter.authorName)
                        .font(.headline)
                        .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255))

                    Text(formattedDate(letter.createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "envelope.fill")
                    .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255).opacity(0.6))
            }

            Text(letter.message)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}
