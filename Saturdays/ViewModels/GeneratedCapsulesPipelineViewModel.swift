//
//  GeneratedCapsulesPipelineViewModel.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/7/25.
//


// GeneratedCapsulesPipelineViewModel.swift

import Foundation
import Combine

final class GeneratedCapsulesPipelineViewModel: ObservableObject {

    @Published var generatedCapsules: [GeneratedCapsuleModel] = []
    @Published var isProcessing: Bool = false

    func runPipeline() {
        print("🚀 [Pipeline] Starting pipeline...")
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
            capsules.append(
                GeneratedCapsuleModel(
                    name: event.title,
                    coverPhoto: cover,
                    photoCount: event.photos.count
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
