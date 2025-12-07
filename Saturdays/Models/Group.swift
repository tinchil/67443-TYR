//
//  Group.swift
//  Saturdays
//
//  Created by Tin 12/2/2025
//

import Foundation

struct GroupModel: Identifiable, Codable, Sendable {
    var id: String
    var name: String
    var memberIDs: [String]
    var capsuleIDs: [String] = []           // List of capsule IDs for this group
    var createdBy: String
    var createdAt: Date
    var coverPhotoURL: String?
}
