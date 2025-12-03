//
//  UserModel.swift
//  Saturdays
//
//  Created by Yining He  on 12/3/25.
//

@preconcurrency import Foundation

struct UserModel: Identifiable, Codable, Sendable {
    var id: String                  // Firebase UID
    var username: String            // @username
    var displayName: String         // Pretty name to show in UI
    var email: String
    var createdAt: Date

    // Friend relationships
    var friendIDs: [String] = []
    var incomingRequests: [String] = []
    var outgoingRequests: [String] = []
}
