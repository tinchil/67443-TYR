//
//  GeneratedCapsulesPipelineViewModel.swift
//  Saturdays
//

import Foundation
import Combine

// ------------------------------------------------
// MARK: - Cache Clear Helper
// ------------------------------------------------

extension PhotoCacheStore {
    func clearCache() {
        print("🗑️ [Cache] Clearing old cache...")

        try? FileManager.default.removeItem(at: cacheURL)
        try? FileManager.default.removeItem(at: thumbnailDirectory)

        print("🗑️ [Cache] Cache + thumbnails deleted.")
    }
}

// ------------------------------------------------
// MARK: - ViewModel
// ------------------------------------------------

final class GeneratedCapsulesPipelineViewModel: ObservableObject {

    @Published var generatedCapsules: [GeneratedCapsuleModel] = []
    @Published var onThisDayCapsules: [GeneratedCapsuleModel] = []
    @Published var isProcessing: Bool = false

    private var hasRun = false

    // ------------------------------------------------
    // MARK: - RUN PIPELINE
    // ------------------------------------------------
    func runPipeline() {
        guard !hasRun else {
            print("⚠️ [Pipeline] Already ran — skipping.")
            return
        }
        hasRun = true

        print("🚀 [Pipeline] Starting pipeline...")
//        PhotoCacheStore.shared.clearCache()
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

    // ------------------------------------------------
    // MARK: - INGEST + CACHE
    // ------------------------------------------------

    private func ingestAndProcess() {
        PhotoLibraryIngestionService.shared.ingestAllPhotos { entries in
            PhotoCacheStore.shared.saveCache(entries)
            self.processCachedPhotos(entries)
        }
    }

    // ------------------------------------------------
    // MARK: - PROCESSING
    // ------------------------------------------------

    private func processCachedPhotos(_ entries: [PhotoMetadataCacheEntry]) {
        print("🧠 [Pipeline] Processing \(entries.count) cached photos...")

        // ---- FACE CLUSTERING (using embeddings) ----
        let faceClusters = FaceClusterService.shared.clusterFacesByEmbedding(from: entries)
        print("🙂 [Pipeline] Generated \(faceClusters.count) face clusters")
        // TODO: Store faceClusters or publish them to UI

        // ---- EVENT CLUSTERING ----
        let eventClusters = EventClusterService.shared.clusterEventsHardcoded(from: entries)

        // ---- CONVERT CLUSTERS → CAPSULE MODELS ----
        print("🎉 [Pipeline] Creating capsules from event clusters...")

        var capsules: [GeneratedCapsuleModel] = []

        for event in eventClusters {
            let cover = event.photos.first?.thumbnailFilename ?? "placeholder"

            let photoIDs = event.photos.map { $0.id }   // REAL IDS for detail screen

            capsules.append(
                GeneratedCapsuleModel(
                    name: event.title,
                    coverPhoto: cover,
                    photoCount: event.photos.count,
                    photoIDs: photoIDs,
                    generatedAt: Date()
                )
            )
        }

        print("🎉 [Pipeline] Generated \(capsules.count) capsules.")

        // ---- COMPUTE ON THIS DAY ----
        computeOnThisDayCapsules(from: capsules, cache: entries)

        DispatchQueue.main.async {
            self.generatedCapsules = capsules
            self.isProcessing = false
        }
    }

    // ------------------------------------------------
    // MARK: - "ON THIS DAY" CAPSULES
    // ------------------------------------------------

    private func computeOnThisDayCapsules(from capsules: [GeneratedCapsuleModel],
                                          cache: [PhotoMetadataCacheEntry])
    {
        let today = Date()
        let cal = Calendar.current

        let todayMonth = cal.component(.month, from: today)
        let todayDay   = cal.component(.day, from: today)
        let currentYear = cal.component(.year, from: today)

        var results: [GeneratedCapsuleModel] = []

        for cap in capsules {
            guard let firstID = cap.photoIDs.first,
                  let entry = cache.first(where: { $0.id == firstID }) else { continue }

            let comps = cal.dateComponents([.month, .day, .year], from: entry.timestamp)

            if comps.month == todayMonth &&
               comps.day == todayDay &&
               comps.year != currentYear
            {
                results.append(cap)
            }
        }

        print("📅 [On This Day] Found \(results.count) throwback capsules")

        DispatchQueue.main.async {
            self.onThisDayCapsules = results
        }
    }
}
