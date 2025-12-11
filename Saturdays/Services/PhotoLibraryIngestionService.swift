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
    // MARK: - FETCH + SELECTION LOGIC
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

        let recentLimit = 20
        let oldestLimit = 20

        print("📸 [Ingestion] Total assets found: \(total)")
        print("⚡ DEMO MODE: newest \(recentLimit) + oldest \(oldestLimit) + OnThisDay photos")

        var selectedAssets: [PHAsset] = []
        selectedAssets.reserveCapacity(recentLimit + oldestLimit)

        // -------------------------------------
        // 1️⃣ NEWEST photos (corrected)
        // assets are oldest → newest
        // newest are at the END
        // -------------------------------------
        if total > 0 {
            let start = max(0, total - recentLimit)
            for i in start..<total {
                selectedAssets.append(assets.object(at: i))
            }
        }

        // -------------------------------------
        // 2️⃣ OLDEST photos (corrected)
        // -------------------------------------
        let oldestCount = min(total, oldestLimit)
        for i in 0..<oldestCount {
            let asset = assets.object(at: i)
            if !selectedAssets.contains(where: { $0.localIdentifier == asset.localIdentifier }) {
                selectedAssets.append(asset)
            }
        }

        print("📸 Selected \(selectedAssets.count) assets before OnThisDay matching")

        // -------------------------------------
        // 3️⃣ Add “On This Day” (same month/day any year)
        // -------------------------------------
        let calendar = Calendar.current
        let today = Date()
        let mToday = calendar.component(.month, from: today)
        let dToday = calendar.component(.day, from: today)

        var onThisDayAssets: [PHAsset] = []

        for i in 0..<total {
            let asset = assets.object(at: i)
            guard let date = asset.creationDate else { continue }

            let m = calendar.component(.month, from: date)
            let d = calendar.component(.day, from: date)

            if m == mToday && d == dToday {
                if !selectedAssets.contains(where: { $0.localIdentifier == asset.localIdentifier }) {
                    onThisDayAssets.append(asset)
                }
            }
        }

        print("📅 [On This Day] Found \(onThisDayAssets.count) matching photos")

        selectedAssets.append(contentsOf: onThisDayAssets)

        print("📦 Final selected asset count: \(selectedAssets.count)")

        // -------------------------------------
        // 4️⃣ Convert → Metadata entries
        // -------------------------------------
        var entries: [PhotoMetadataCacheEntry] = []
        entries.reserveCapacity(selectedAssets.count)

        for (idx, asset) in selectedAssets.enumerated() {
            print("📸 [Ingestion] Processing \(idx + 1)/\(selectedAssets.count): \(asset.localIdentifier)")
            if let entry = await processSingleAsset(asset) {
                entries.append(entry)
            }
        }

        print("📦 [Ingestion] Created metadata for \(entries.count) assets.")
        return entries
    }

    // -------------------------------------------------------
    // MARK: - PROCESS SINGLE ASSET
    // -------------------------------------------------------

    private func processSingleAsset(_ asset: PHAsset) async -> PhotoMetadataCacheEntry? {

        guard let image = await fetchUIImage(from: asset) else {
            print("❌ [Thumbnail] Could not read image data for \(asset.localIdentifier)")
            return nil
        }

        let thumbnail = image.resizeTo(maxDimension: 300)

        guard let filename = saveThumbnail(thumbnail, for: asset) else {
            print("❌ [Thumbnail] Failed saving thumbnail for \(asset.localIdentifier)")
            return nil
        }

        // ---------------------------------------------------
        // ⭐ NEW: Generate Vision face embedding for clustering
        // ---------------------------------------------------
        // 1. Extract face IDs from the image (convert UIImage → fake PHAsset wrapper)
        let faceIDs = await FaceEmbeddingService.shared.getFaceIdentifiers(for: asset) ?? []

        // 2. Convert face IDs → 128-dim embedding
        let embedding = FaceEmbeddingService.shared.generateEmbeddingFromFaceIDs(faceIDs)


        return PhotoMetadataCacheEntry(
            id: asset.localIdentifier,
            timestamp: asset.creationDate ?? Date(),
            latitude: asset.location?.coordinate.latitude,
            longitude: asset.location?.coordinate.longitude,
            thumbnailFilename: filename,
            faceEmbedding: embedding,   // ⭐ ADDED
            sceneEmbedding: nil
        )
    }


    // -------------------------------------------------------
    // MARK: - IMAGE EXTRACTION
    // -------------------------------------------------------

    private func fetchUIImage(from asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let opts = PHImageRequestOptions()
            opts.deliveryMode = .highQualityFormat
            opts.isNetworkAccessAllowed = true
            opts.isSynchronous = false

            PHImageManager.default().requestImageDataAndOrientation(
                for: asset,
                options: opts
            ) { data, _, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    // -------------------------------------------------------
    // MARK: - SAVE THUMBNAIL
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
// MARK: - UIImage Resize Helper
//

extension UIImage {
    func resizeTo(maxDimension: CGFloat) -> UIImage {
        let maxSide = max(size.width, size.height)
        let scale = maxDimension / maxSide

        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
