//
//  LetterModel.swift
//  Saturdays
//
//  Created for Letter Capsule feature
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct LetterModel: Identifiable, Codable, Sendable {
    var id: String                      // Unique ID for this letter
    var authorID: String                // UID of the person who wrote it
    var authorName: String              // Display name of author
    var message: String                 // The letter content
    var createdAt: Date                 // When the letter was written

    // Convenience initializer
    init(
        id: String = UUID().uuidString,
        authorID: String = Auth.auth().currentUser?.uid ?? "",
        authorName: String = "",
        message: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.authorID = authorID
        self.authorName = authorName
        self.message = message
        self.createdAt = createdAt
    }
}
