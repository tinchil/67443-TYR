// PhotoCacheStore.swift

import Foundation
import UIKit

final class PhotoCacheStore {

    static let shared = PhotoCacheStore()
    private init() {}

    var cacheURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("photo_cache.json")
    }

    var thumbnailDirectory: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("thumbnails")
        if !FileManager.default.fileExists(atPath: dir.path) {
            print("📁 [Cache] Creating thumbnails directory")
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    func loadCache() -> [PhotoMetadataCacheEntry] {
        print("📦 [Cache] Loading cached metadata...")

        guard let data = try? Data(contentsOf: cacheURL) else {
            print("⚠️ [Cache] No cache found.")
            return []
        }

        let decoded = (try? JSONDecoder().decode([PhotoMetadataCacheEntry].self, from: data)) ?? []
        print("📦 [Cache] Loaded \(decoded.count) cached photos.")
        return decoded
    }

    func saveCache(_ photos: [PhotoMetadataCacheEntry]) {
        print("💾 [Cache] Saving \(photos.count) photos to cache...")
        let data = try? JSONEncoder().encode(photos)
        try? data?.write(to: cacheURL)
        print("💾 [Cache] Saved cache successfully.")
    }
}

extension PhotoCacheStore {
    func loadEntry(for id: String) -> PhotoMetadataCacheEntry? {
        let all = loadCache()
        return all.first(where: { $0.id == id })
    }
}

extension PhotoCacheStore {
    func loadThumbnail(filename: String) -> UIImage? {
        let url = thumbnailDirectory.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
