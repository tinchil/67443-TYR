//
//  GeneratedCapsulesPipelineViewModel.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/7/25.
//


// GeneratedCapsulesPipelineViewModel.swift

import Foundation
import Combine

extension PhotoCacheStore {
    func clearCache() {
        print("🗑️ [Cache] Clearing old cache...")

        try? FileManager.default.removeItem(at: cacheURL)
        try? FileManager.default.removeItem(at: thumbnailDirectory)

        print("🗑️ [Cache] Cache + thumbnails deleted.")
    }
}

final class GeneratedCapsulesPipelineViewModel: ObservableObject {

    @Published var generatedCapsules: [GeneratedCapsuleModel] = []
    @Published var isProcessing: Bool = false
    private var hasRun = false

    func runPipeline() {
            // Prevent running more than once per app launch
            guard !hasRun else {
                print("⚠️ [Pipeline] Already ran — skipping.")
                return
            }
            hasRun = true

            print("🚀 [Pipeline] Starting pipeline...")

            // ❗️REMOVE THIS after first dev test
            // PhotoCacheStore.shared.clearCache()

            isProcessing = true

            let cache = PhotoCacheStore.shared.loadCache()

            if cache.isEmpty {
                print("⚠️ [Pipeline] Cache empty → starting ingestion.")
                ingestAndProcess()
            } else {
                print("📦 [Pipeline] Using cached photo metadata.")
                processCachedPhotos(cache)
            }
        }


    private func ingestAndProcess() {
        PhotoLibraryIngestionService.shared.ingestAllPhotos { entries in
            PhotoCacheStore.shared.saveCache(entries)
            self.processCachedPhotos(entries)
        }
    }

    private func processCachedPhotos(_ entries: [PhotoMetadataCacheEntry]) {
        print("🧠 [Pipeline] Processing \(entries.count) cached photos...")

        // ---------- FACE CLUSTERING ----------
        let faceClusters = FaceClusterService.shared.clusterFacesHardcoded(from: entries)

        // ---------- EVENT CLUSTERING ----------
        let eventClusters = EventClusterService.shared.clusterEventsHardcoded(from: entries)

        // ---------- GENERATE CAPSULES ----------
        print("🎉 [Pipeline] Creating capsules from event clusters...")

        var capsules: [GeneratedCapsuleModel] = []

        for event in eventClusters {
            let cover = event.photos.first?.thumbnailFilename ?? "placeholder"

            let photoIDs = event.photos.map { $0.id }   // ← CACHE ENTRY IDS

            capsules.append(
                GeneratedCapsuleModel(
                    name: event.title,
                    coverPhoto: cover,
                    photoCount: event.photos.count,
                    photoIDs: photoIDs
                )
            )
        }

        print("🎉 [Pipeline] Generated \(capsules.count) capsules.")

        DispatchQueue.main.async {
            self.generatedCapsules = capsules
            self.isProcessing = false
        }
    }
}
