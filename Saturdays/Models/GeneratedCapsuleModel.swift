//
//  GeneratedCapsuleModel.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/7/25.
//


import Foundation
import SwiftUI

struct GeneratedCapsuleModel: Identifiable, Codable {
    var id = UUID().uuidString
    var name: String
    var coverPhoto: String          // thumbnail filename
    var photoCount: Int
    var photoIDs: [String]          // ← REAL ENTRY IDs
    var generatedAt: Date = Date()
}
