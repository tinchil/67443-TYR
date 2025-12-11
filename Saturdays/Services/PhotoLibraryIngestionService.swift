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

        let recentLimit = 20
        let oldestLimit = 20

        print("📸 [Ingestion] Total assets found: \(total)")
        print("⚡ DEMO MODE: ingesting first \(recentLimit) recent + last \(oldestLimit) oldest photos + all On This Day photos")

        var selectedAssets: [PHAsset] = []
        selectedAssets.reserveCapacity(recentLimit + oldestLimit)

        // -------------------------------------
        // 1️⃣ Most RECENT N photos
        // -------------------------------------
        let recentCount = min(total, recentLimit)
        for index in 0..<recentCount {
            selectedAssets.append(assets.object(at: index))
        }

        // -------------------------------------
        // 2️⃣ Most OLDEST N photos
        // -------------------------------------
        if total > recentLimit {
            let start = max(0, total - oldestLimit)
            for index in start..<total {
                let asset = assets.object(at: index)
                if !selectedAssets.contains(where: { $0.localIdentifier == asset.localIdentifier }) {
                    selectedAssets.append(asset)
                }
            }
        }

        print("📸 Selected \(selectedAssets.count) assets before OnThisDay matching")

        // -------------------------------------
        // 3️⃣ Add “On This Day” photos (all years)
        // -------------------------------------
        let calendar = Calendar.current
        let today = Date()
        let todayMonth = calendar.component(.month, from: today)
        let todayDay   = calendar.component(.day, from: today)

        var onThisDayAssets: [PHAsset] = []

        for i in 0..<total {
            let asset = assets.object(at: i)
            guard let date = asset.creationDate else { continue }

            let m = calendar.component(.month, from: date)
            let d = calendar.component(.day, from: date)

            if m == todayMonth && d == todayDay {
                if !selectedAssets.contains(where: { $0.localIdentifier == asset.localIdentifier }) {
                    onThisDayAssets.append(asset)
                }
            }
        }

        print("📅 [On This Day] Found \(onThisDayAssets.count) matching photos")

        selectedAssets.append(contentsOf: onThisDayAssets)

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

        print("📦 [Ingestion] Completed metadata for \(entries.count) assets.")
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

        // 4. Get face identifiers from Photos framework
        let faceIDs = await FaceEmbeddingService.shared.getFaceIdentifiers(for: asset)

        // 5. Generate embedding from face IDs
        let faceEmbedding: [Float]?
        if let faceIDs = faceIDs {
            faceEmbedding = FaceEmbeddingService.shared.generateEmbeddingFromFaceIDs(faceIDs)
            print("✅ [Embedding] Generated face embedding for \(asset.localIdentifier) from \(faceIDs.count) face(s)")
        } else {
            faceEmbedding = nil
            print("ℹ️ [Embedding] No faces detected in \(asset.localIdentifier)")
        }

        // 6. Build entry
        return PhotoMetadataCacheEntry(
            id: asset.localIdentifier,
            timestamp: asset.creationDate ?? Date(),
            latitude: asset.location?.coordinate.latitude,
            longitude: asset.location?.coordinate.longitude,
            thumbnailFilename: filename,
            faceEmbedding: faceEmbedding,
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
