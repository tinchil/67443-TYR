//
//  CapsuleModel.swift
//  Saturdays
//
//  Created by Yining He  on 11/30/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CapsuleModel: Identifiable, Codable, Sendable {
    var id: String                          // Firestore document ID
    var name: String                        // Capsule name
    var type: CapsuleType                   // memory or letter
    var groupID: String                     // Which group this capsule belongs to
    var createdBy: String                   // UID of creator
    var createdAt: Date                     // When created
    var mediaURLs: [String]                 // URLs of uploaded images/videos
    var finalVideoURL: String?              // URL of the compiled final video
    var coverPhotoURL: String?              // URL of cover photo

    // Convenience initializer for creating new capsules in UI
    init(
        id: String = UUID().uuidString,
        name: String = "",
        type: CapsuleType,
        groupID: String = "",
        createdBy: String = Auth.auth().currentUser?.uid ?? "",
        createdAt: Date = Date(),
        mediaURLs: [String] = [],
        finalVideoURL: String? = nil,
        coverPhotoURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.groupID = groupID
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.mediaURLs = mediaURLs
        self.finalVideoURL = finalVideoURL
        self.coverPhotoURL = coverPhotoURL
    }
}


