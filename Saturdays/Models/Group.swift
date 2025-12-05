//
//  Group.swift
//  Saturdays
//
//  Created by Tin 12/2/2025
//

import Foundation

struct GroupModel: Identifiable, Codable {
    var id: String
    var name: String
    var memberIDs: [String]
    var createdBy: String
    var createdAt: Date
    var coverPhotoURL: String?
}
