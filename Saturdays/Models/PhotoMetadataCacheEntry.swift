//
//  PhotoMetadataCacheEntry.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/7/25.
//


//
//  PhotoMetadataCacheEntry.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/7/25.
//

import Foundation
import CoreLocation

/// Lightweight, disk-cached representation of a photo.
/// Safe to store thousands of these without memory issues.
struct PhotoMetadataCacheEntry: Identifiable, Codable {

    /// Unique identifier that ties back to PHAsset.localIdentifier.
    let id: String

    /// Date the photo was created.
    let timestamp: Date

    /// Optional GPS coordinates.
    let latitude: Double?
    let longitude: Double?

    /// The filename of the cached thumbnail stored on disk.
    let thumbnailFilename: String

    /// (Optional) Reserved for CoreML embeddings (face, scene, etc.)
    /// These should not be UIImage or Data — only numeric vectors.
    var faceEmbedding: [Float]? = nil
    var sceneEmbedding: [Float]? = nil

    /// Convenience to turn metadata into CLLocation for clustering.
    var location: CLLocation? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocation(latitude: lat, longitude: lon)
    }
}
