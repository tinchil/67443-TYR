// PhotoMetadataExtractor.swift

import Foundation
import UIKit
import CoreLocation
import Combine

final class PhotoMetadataExtractor {

    static func toPhotoItem(_ entry: PhotoMetadataCacheEntry) -> PhotoItem {

        let thumbURL = PhotoCacheStore.shared.thumbnailDirectory
            .appendingPathComponent(entry.thumbnailFilename)

        let didLoad = FileManager.default.fileExists(atPath: thumbURL.path)
        print("🧩 [Extractor] Loading PhotoItem for id=\(entry.id), thumbnail exists? \(didLoad)")

        let image = UIImage(contentsOfFile: thumbURL.path) ?? UIImage()

        let location: CLLocation?
        if let lat = entry.latitude, let lon = entry.longitude {
            location = CLLocation(latitude: lat, longitude: lon)
        } else {
            location = nil
        }

        return PhotoItem(
            image: image,
            location: location,
            timestamp: entry.timestamp
        )
    }
}
