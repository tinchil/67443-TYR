//
//  Friend.swift
//  Saturdays
//
//  Created by Claude Code
//

import Foundation


struct Friend: Identifiable, Codable, Sendable {
    var id: String              // Unique friend doc id = friend.userID
    var userID: String          // UID of the friend
    var username: String
    var displayName: String
    var createdAt: Date
}


struct FriendRequest: Identifiable, Codable, Sendable {
    var id: String                  // "{fromID}_to_{toID}"
    var fromUserID: String
    var fromUsername: String
    var fromDisplayName: String
    var toUserID: String
    var createdAt: Date
}
