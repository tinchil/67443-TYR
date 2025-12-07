//
//  GeneratedCapsuleModel.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/7/25.
//


import Foundation
import SwiftUI

struct GeneratedCapsuleModel: Identifiable {
    var id = UUID().uuidString
    var name: String
    var coverPhoto: String      // local asset for demo
    var photoCount: Int
    var generatedAt: Date = Date()
}
