//
//  CapsuleService.swift
//  Saturdays
//
//  Created by Tin 12/5/2025
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class CapsuleService {

    private let db = Firestore.firestore()

    private var currentUserID: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    // MARK: - CREATE CAPSULE
    func createCapsule(
        name: String,
        type: CapsuleType,
        groupID: String,
        mediaURLs: [String] = [],
        letters: [LetterModel] = [],
        revealDate: Date? = nil,
        minContribution: Int? = nil,
        completion: @escaping (String?) -> Void
    ) {
        let capsuleID = UUID().uuidString
        let batch = db.batch()

        // Create the capsule document in capsules collection
        let capsuleRef = db.collection("capsules").document(capsuleID)

        // Convert letters to dictionaries for Firestore
        let lettersData = letters.map { letter -> [String: Any] in
            return [
                "id": letter.id,
                "authorID": letter.authorID,
                "authorName": letter.authorName,
                "message": letter.message,
                "createdAt": letter.createdAt
            ]
        }

        var data: [String: Any] = [
            "id": capsuleID,
            "name": name,
            "type": type.rawValue,
            "groupID": groupID,
            "createdBy": currentUserID,
            "createdAt": Date(),
            "mediaURLs": mediaURLs,
            "letters": lettersData,
            "finalVideoURL": NSNull(),
            "coverPhotoURL": NSNull()
        ]

        // Add optional fields if provided
        if let revealDate = revealDate {
            data["revealDate"] = revealDate
        }
        if let minContribution = minContribution {
            data["minContribution"] = minContribution
        }

        batch.setData(data, forDocument: capsuleRef)

        // Add capsuleID to the group's capsuleIDs array
        let groupRef = db.collection("groups").document(groupID)
        batch.setData([
            "capsuleIDs": FieldValue.arrayUnion([capsuleID])
        ], forDocument: groupRef, merge: true)

        batch.commit { error in
            if let error = error {
                print("❌ Error creating capsule: \(error.localizedDescription)")
                completion(nil)
            } else {
                print("✅ Capsule '\(name)' created successfully with ID: \(capsuleID)")
                print("📋 Added to group: \(groupID)")
                completion(capsuleID)
            }
        }
    }

    // MARK: - UPDATE CAPSULE MEDIA
    func updateCapsuleMedia(
        capsuleID: String,
        mediaURLs: [String],
        completion: @escaping (Bool) -> Void
    ) {
        db.collection("capsules").document(capsuleID).updateData([
            "mediaURLs": mediaURLs
        ]) { error in
            if let error = error {
                print("❌ Error updating capsule media: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Updated capsule media: \(mediaURLs.count) URLs")
                completion(true)
            }
        }
    }

    // MARK: - UPDATE CAPSULE LETTERS
    func updateCapsuleLetters(
        capsuleID: String,
        letters: [LetterModel],
        completion: @escaping (Bool) -> Void
    ) {
        // Convert letters to dictionaries for Firestore
        let lettersData = letters.map { letter -> [String: Any] in
            return [
                "id": letter.id,
                "authorID": letter.authorID,
                "authorName": letter.authorName,
                "message": letter.message,
                "createdAt": letter.createdAt
            ]
        }

        db.collection("capsules").document(capsuleID).updateData([
            "letters": lettersData
        ]) { error in
            if let error = error {
                print("❌ Error updating capsule letters: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Updated capsule letters: \(letters.count) letters")
                completion(true)
            }
        }
    }

    // MARK: - UPDATE CAPSULE NAME
    func updateCapsuleName(
        capsuleID: String,
        name: String,
        completion: @escaping (Bool) -> Void
    ) {
        db.collection("capsules").document(capsuleID).updateData([
            "name": name
        ]) { error in
            if let error = error {
                print("❌ Error updating capsule name: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Updated capsule name to: \(name)")
                completion(true)
            }
        }
    }

    // MARK: - UPDATE FINAL VIDEO URL
    func updateFinalVideoURL(
        capsuleID: String,
        finalVideoURL: String,
        completion: @escaping (Bool) -> Void
    ) {
        db.collection("capsules").document(capsuleID).updateData([
            "finalVideoURL": finalVideoURL
        ]) { error in
            if let error = error {
                print("❌ Error updating final video URL: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Updated final video URL for capsule")
                completion(true)
            }
        }
    }

    // MARK: - FETCH GROUP CAPSULES (One-time fetch)
    func fetchGroupCapsules(groupID: String, completion: @escaping ([CapsuleModel]) -> Void) {
        db.collection("capsules")
            .whereField("groupID", isEqualTo: groupID)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in

                if let error = error {
                    print("❌ Error fetching capsules: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let capsules = snapshot?.documents.compactMap {
                    try? $0.data(as: CapsuleModel.self)
                } ?? []

                print("📋 Fetched \(capsules.count) capsules for group \(groupID)")
                completion(capsules)
            }
    }

    // MARK: - DELETE CAPSULE
    func deleteCapsule(capsuleID: String, groupID: String, completion: @escaping (Bool) -> Void) {
        let batch = db.batch()

        // Delete the capsule document
        let capsuleRef = db.collection("capsules").document(capsuleID)
        batch.deleteDocument(capsuleRef)

        // Remove capsuleID from group's capsuleIDs array
        let groupRef = db.collection("groups").document(groupID)
        batch.setData([
            "capsuleIDs": FieldValue.arrayRemove([capsuleID])
        ], forDocument: groupRef, merge: true)

        batch.commit { error in
            if let error = error {
                print("❌ Error deleting capsule: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Capsule deleted successfully")
                completion(true)
            }
        }
    }

    // MARK: - REALTIME LISTENER FOR GROUP CAPSULES
    func listenForGroupCapsules(
        groupID: String,
        completion: @escaping ([CapsuleModel]) -> Void
    ) -> ListenerRegistration {

        return db.collection("capsules")
            .whereField("groupID", isEqualTo: groupID)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    print("❌ Error listening for capsules: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let capsules = snapshot?.documents.compactMap {
                    try? $0.data(as: CapsuleModel.self)
                } ?? []

                print("📤 Returning \(capsules.count) capsules for group \(groupID)")
                completion(capsules)
            }
    }

    // MARK: - FETCH ALL USER CAPSULES (across all their groups)
    func fetchUserCapsules(completion: @escaping ([CapsuleModel]) -> Void) {
        guard !currentUserID.isEmpty else {
            print("❌ No current user ID")
            completion([])
            return
        }

        // First, get all groups the user belongs to
        db.collection("users").document(currentUserID).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching user's groups: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let data = snapshot?.data(),
                  let groupIDs = data["groupIDs"] as? [String],
                  !groupIDs.isEmpty else {
                print("ℹ️ No groups found for user")
                completion([])
                return
            }

            // Fetch capsules for all groups
            self.db.collection("capsules")
                .whereField("groupID", in: groupIDs)
                .order(by: "createdAt", descending: true)
                .getDocuments { snapshot, error in

                    if let error = error {
                        print("❌ Error fetching user capsules: \(error.localizedDescription)")
                        completion([])
                        return
                    }

                    let capsules = snapshot?.documents.compactMap {
                        try? $0.data(as: CapsuleModel.self)
                    } ?? []

                    print("📋 Fetched \(capsules.count) total capsules across all user's groups")
                    completion(capsules)
                }
        }
    }
}
