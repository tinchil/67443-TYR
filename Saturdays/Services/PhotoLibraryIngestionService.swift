// PhotoLibraryIngestionService.swift
// Saturdays

import Foundation
import Photos
import CoreLocation
import UIKit

final class PhotoLibraryIngestionService: NSObject {

    static let shared = PhotoLibraryIngestionService()
    private override init() {}

    func ingestAllPhotos(completion: @escaping ([PhotoMetadataCacheEntry]) -> Void) {

        print("📸 [Ingestion] Requesting authorization...")
        PHPhotoLibrary.requestAuthorization { status in
            print("📸 [Ingestion] Authorization status: \(status.rawValue)")

            guard status == .authorized || status == .limited else {
                print("❌ [Ingestion] Permission denied.")
                completion([])
                return
            }

            let assets = PHAsset.fetchAssets(with: .image, options: nil)
            print("📸 [Ingestion] Found \(assets.count) photos in library.")

            var entries: [PhotoMetadataCacheEntry] = []
            let imageManager = PHImageManager.default()

            let options = PHImageRequestOptions()
            options.version = .original
            options.resizeMode = .fast
            options.deliveryMode = .fastFormat
            options.isSynchronous = true

            assets.enumerateObjects { asset, idx, _ in
                print("📸 [Ingestion] Processing asset \(idx + 1)/\(assets.count), id: \(asset.localIdentifier)")

                let timestamp = asset.creationDate ?? Date()
                let loc = asset.location

                var thumbnailName = ""
                let targetSize = CGSize(width: 150, height: 150)

                imageManager.requestImage(
                    for: asset,
                    targetSize: targetSize,
                    contentMode: .aspectFill,
                    options: options
                ) { image, _ in
                    if let image = image {
                        print("🖼️  [Ingestion] Generated thumbnail for \(asset.localIdentifier)")
                        thumbnailName = self.storeThumbnail(image: image, id: asset.localIdentifier)
                    } else {
                        print("❌ [Ingestion] Failed thumbnail for \(asset.localIdentifier)")
                    }
                }

                let entry = PhotoMetadataCacheEntry(
                    id: asset.localIdentifier,
                    timestamp: timestamp,
                    latitude: loc?.coordinate.latitude,
                    longitude: loc?.coordinate.longitude,
                    thumbnailFilename: thumbnailName
                )

                entries.append(entry)
            }

            DispatchQueue.main.async {
                print("📦 [Ingestion] Completed ingestion of \(entries.count) photos.")
                completion(entries)
            }
        }
    }

    private func storeThumbnail(image: UIImage, id: String) -> String {
        let filename = "\(id.replacingOccurrences(of: "/", with: "_")).jpg"
        let url = PhotoCacheStore.shared.thumbnailDirectory.appendingPathComponent(filename)

        if let data = image.jpegData(compressionQuality: 0.5) {
            try? data.write(to: url)
            print("💾 [Ingestion] Saved thumbnail: \(filename)")
        } else {
            print("❌ [Ingestion] Failed to save thumbnail for \(id)")
        }

        return filename
    }
}
