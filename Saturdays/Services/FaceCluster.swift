//
//  FaceCluster.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/7/25.
//

import Foundation
import Accelerate

struct FaceCluster {
    let clusterID: Int
    let photoIDs: [String]
}

final class FaceClusterService {

    static let shared = FaceClusterService()
    private init() {}

    // MARK: - Similarity Threshold
    // Cosine similarity threshold (0 to 1, where 1 = identical faces)
    // Typical values: 0.6-0.8 for same person
    private let similarityThreshold: Float = 0.7

    // MARK: - Main Clustering Function

    /// Clusters photos based on face embeddings using cosine similarity
    func clusterFacesByEmbedding(from photos: [PhotoMetadataCacheEntry]) -> [FaceCluster] {
        print("🙂 [FaceCluster] Starting embedding-based clustering...")

        // Filter photos that have face embeddings
        let photosWithFaces = photos.filter { $0.faceEmbedding != nil }

        guard !photosWithFaces.isEmpty else {
            print("⚠️ [FaceCluster] No photos with face embeddings found")
            return []
        }

        print("🙂 [FaceCluster] Found \(photosWithFaces.count) photos with face embeddings")

        // Cluster using simple agglomerative approach
        var clusters: [[PhotoMetadataCacheEntry]] = []

        for photo in photosWithFaces {
            guard let embedding = photo.faceEmbedding else { continue }

            // Try to find a matching cluster
            var foundCluster = false

            for i in 0..<clusters.count {
                // Check similarity with first photo in cluster (representative)
                if let firstPhotoEmbedding = clusters[i].first?.faceEmbedding {
                    let similarity = cosineSimilarity(embedding, firstPhotoEmbedding)

                    if similarity >= similarityThreshold {
                        clusters[i].append(photo)
                        foundCluster = true
                        break
                    }
                }
            }

            // Create new cluster if no match found
            if !foundCluster {
                clusters.append([photo])
            }
        }

        print("🙂 [FaceCluster] Created \(clusters.count) clusters")

        // Convert to FaceCluster format
        let faceClusters = clusters.enumerated().map { index, photoGroup in
            let photoIDs = photoGroup.map { $0.id }
            print("🙂 [FaceCluster] Cluster \(index) = \(photoIDs.count) photos")
            return FaceCluster(clusterID: index, photoIDs: photoIDs)
        }

        // Filter out clusters with only 1 photo (optional)
        return faceClusters.filter { $0.photoIDs.count > 1 }
    }

    // MARK: - Hardcoded Fallback (for testing)

    /// Hardcoded: last 10 photos form 2 fake clusters.
    func clusterFacesHardcoded(from photos: [PhotoMetadataCacheEntry]) -> [FaceCluster] {

        let last10 = Array(photos.suffix(10))
        let ids = last10.map { $0.id }

        print("🙂 [FaceCluster] Hardcoded clustering on last \(ids.count) photos")

        let clusterA = Array(ids.prefix(ids.count/2))
        let clusterB = Array(ids.suffix(ids.count/2))

        print("🙂 [FaceCluster] Cluster A = \(clusterA.count) photos")
        print("🙂 [FaceCluster] Cluster B = \(clusterB.count) photos")

        return [
            FaceCluster(clusterID: 0, photoIDs: clusterA),
            FaceCluster(clusterID: 1, photoIDs: clusterB)
        ]
    }

    // MARK: - Cosine Similarity

    /// Computes cosine similarity between two embedding vectors
    /// Returns a value between -1 and 1 (typically 0 to 1 for face embeddings)
    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count else {
            print("❌ Embedding dimensions don't match: \(a.count) vs \(b.count)")
            return 0
        }

        var dotProduct: Float = 0
        var magnitudeA: Float = 0
        var magnitudeB: Float = 0

        vDSP_dotpr(a, 1, b, 1, &dotProduct, vDSP_Length(a.count))
        vDSP_svesq(a, 1, &magnitudeA, vDSP_Length(a.count))
        vDSP_svesq(b, 1, &magnitudeB, vDSP_Length(b.count))

        let magnitude = sqrt(magnitudeA) * sqrt(magnitudeB)

        guard magnitude > 0 else { return 0 }

        return dotProduct / magnitude
    }
}
