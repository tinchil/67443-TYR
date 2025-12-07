//
//  PhotoLibraryIngestionService.swift
//  Saturdays
//
//  Created by ChatGPT Fix Build
//

import Foundation
import Photos
import UIKit

final class PhotoLibraryIngestionService {

    static let shared = PhotoLibraryIngestionService()
    private init() {}

    // -------------------------------------------------------
    // MARK: - PUBLIC INGEST FUNCTION
    // -------------------------------------------------------

    func ingestAllPhotos(completion: @escaping ([PhotoMetadataCacheEntry]) -> Void) {
        print("📸 [Ingestion] Requesting authorization...")

        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                print("❌ [Ingestion] Not authorized to read photo library.")
                completion([])
                return
            }

            Task {
                let result = await self.loadAllPhotos()
                completion(result)
            }
        }
    }

    // -------------------------------------------------------
    // MARK: - ASYNC INGEST LOGIC
    // -------------------------------------------------------

    private func fetchAllAssets() -> PHFetchResult<PHAsset> {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: true)
        ]
        return PHAsset.fetchAssets(with: fetchOptions)
    }

    private func loadAllPhotos() async -> [PhotoMetadataCacheEntry] {
        let assets = fetchAllAssets()
        let total = assets.count
        let demoIngestionLimit = 20

        print("📸 [Ingestion] Total assets found: \(total)")
        print("⚡ Using DEMO MODE: limiting ingestion to \(demoIngestionLimit) photos")

        var entries: [PhotoMetadataCacheEntry] = []
        entries.reserveCapacity(min(total, demoIngestionLimit))

        let count = min(total, demoIngestionLimit)

        for index in 0..<count {
            let asset = assets.object(at: index)
            print("📸 [Ingestion] Processing asset \(index+1)/\(count), id: \(asset.localIdentifier)")

            if let entry = await processSingleAsset(asset) {
                entries.append(entry)
                print("📸 [Ingestion] Added entry for \(asset.localIdentifier)")
            } else {
                print("❌ [Ingestion] Failed processing \(asset.localIdentifier)")
            }
        }

        print("📦 [Ingestion] Completed ingestion of \(entries.count) assets.")
        return entries
    }


    // -------------------------------------------------------
    // MARK: - PROCESS SINGLE ASSET
    // -------------------------------------------------------

    private func processSingleAsset(_ asset: PHAsset) async -> PhotoMetadataCacheEntry? {

        // 1. Fetch FULL image data (works for HEIC, RAW, Live Photo)
        guard let image = await fetchUIImage(from: asset) else {
            print("❌ [Thumbnail] Could not read image data for \(asset.localIdentifier)")
            return nil
        }

        // 2. Resize into a ~300px thumbnail
        let thumbnail = image.resizeTo(maxDimension: 300)

        // 3. Save thumbnail to disk
        guard let filename = saveThumbnail(thumbnail, for: asset) else {
            print("❌ [Thumbnail] Failed saving thumbnail for \(asset.localIdentifier)")
            return nil
        }

        // 4. Build entry
        return PhotoMetadataCacheEntry(
            id: asset.localIdentifier,
            timestamp: asset.creationDate ?? Date(),
            latitude: asset.location?.coordinate.latitude,
            longitude: asset.location?.coordinate.longitude,
            thumbnailFilename: filename,
            faceEmbedding: nil,
            sceneEmbedding: nil
        )
    }

    // -------------------------------------------------------
    // MARK: - IMAGE EXTRACTION (THE FIX)
    // -------------------------------------------------------

    private func fetchUIImage(from asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = false
            options.isNetworkAccessAllowed = true

            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) {
                data, _, _, _ in
                if let data = data, let img = UIImage(data: data) {
                    continuation.resume(returning: img)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    // -------------------------------------------------------
    // MARK: - SAVE THUMBNAIL TO DISK
    // -------------------------------------------------------

    private func saveThumbnail(_ thumbnail: UIImage, for asset: PHAsset) -> String? {
        guard let jpeg = thumbnail.jpegData(compressionQuality: 0.7) else { return nil }

        let hashed = "\(asset.localIdentifier.hashValue)"
        let filename = "thumb_\(hashed).jpg"

        let url = PhotoCacheStore.shared.thumbnailDirectory
            .appendingPathComponent(filename)

        do {
            try jpeg.write(to: url)
            print("📸 [Thumbnail] Saved \(filename)")
            return filename
        } catch {
            print("❌ [Thumbnail] Error writing file: \(error)")
            return nil
        }
    }
}



//
//  UIImage Resize Helper
//

extension UIImage {
    func resizeTo(maxDimension: CGFloat) -> UIImage {
        let maxSide = max(size.width, size.height)
        let scale = maxDimension / maxSide

        let newSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )

        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        defer { UIGraphicsEndImageContext() }

        self.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
