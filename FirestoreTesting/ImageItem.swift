//
//  ImageItem.swift
//  Saturdays
//
//  Created by Tin on 10/26/25.
//

import Foundation
import FirebaseFirestore

struct ImageItem: Identifiable, Codable {
    @DocumentID var id: String?
    var url: String
    var caption: String
    var uploadedAt: Date
}
