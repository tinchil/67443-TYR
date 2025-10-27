//
//  ImageRepository.swift
//  Saturdays
//
//  Created by Tin on 10/26/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import Combine
import UIKit

class ImageRepository: ObservableObject {
    // MARK: - Properties
    private let path = "images"                   // Firestore collection name
    private let store = Firestore.firestore()     // Firestore reference
    private let storage = Storage.storage()       // Firebase Storage reference
    
    @Published var images: [ImageItem] = []       // Published list of images (auto-updates in SwiftUI)
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Init
    init() {
        get()
    }

    // MARK: - Get Images (Real-time listener)
    func get() {
        store.collection(path)
            .order(by: "uploadedAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error fetching images: \(error.localizedDescription)")
                    return
                }
                
                self.images = snapshot?.documents.compactMap {
                    try? $0.data(as: ImageItem.self)
                } ?? []
                
                print("📸 Loaded \(self.images.count) image(s) from Firestore.")
            }
    }

    // MARK: - Add Demo Image
    func addDemoImage(caption: String) {
        // 1️⃣ Pick a random demo image from your Assets.xcassets
        let demoImages = ["Demo1", "Demo2", "Demo3"]   // replace with your asset names
        guard let randomName = demoImages.randomElement(),
              let image = UIImage(named: randomName),
              let data = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Could not find demo image in assets.")
            return
        }

        // 2️⃣ Create a unique file path in Firebase Storage
        let filename = UUID().uuidString + ".jpg"
        let ref = storage.reference().child("images/\(filename)")

        // 3️⃣ Upload to Storage
        ref.putData(data) { _, error in
            if let error = error {
                print("❌ Upload failed: \(error.localizedDescription)")
                return
            }

            // 4️⃣ Get download URL
            ref.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("❌ Failed to retrieve download URL.")
                    return
                }

                // 5️⃣ Create Firestore document
                let newImage = ImageItem(
                    url: downloadURL.absoluteString,
                    caption: caption.isEmpty ? "Demo upload (\(randomName))" : caption,
                    uploadedAt: Date()
                )

                do {
                    try self.store.collection(self.path).addDocument(from: newImage)
                    print("✅ Uploaded \(randomName) successfully!")
                } catch {
                    print("❌ Firestore write error: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Delete Image (optional)
    func delete(_ image: ImageItem) {
        guard let id = image.id else { return }
        store.collection(path).document(id).delete { error in
            if let error = error {
                print("❌ Delete failed: \(error.localizedDescription)")
            } else {
                print("🗑️ Deleted image: \(id)")
            }
        }
    }
}
