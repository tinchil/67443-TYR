//
//  PhotoMetadataCacheEntry.swift
//  Saturdays
//

import Foundation
import CoreLocation

struct PhotoMetadataCacheEntry: Identifiable, Codable {

    let id: String
    let timestamp: Date
    let latitude: Double?
    let longitude: Double?

    /// Cached thumbnail filename
    let thumbnailFilename: String

    /// Added: Vision embedding support
    var faceEmbedding: [Float]? = nil
    var sceneEmbedding: [Float]? = nil

    var location: CLLocation? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocation(latitude: lat, longitude: lon)
    }
}
