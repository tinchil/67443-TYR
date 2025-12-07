//
//  FaceCluster.swift
//  Saturdays
//
import Foundation

struct FaceCluster: Identifiable {
    let id = UUID()
    let photos: [PhotoMetadataCacheEntry]
    let title: String
}

final class FaceClusterService {

    static let shared = FaceClusterService()
    private init() {}

    func clusterFaces(
        from photos: [PhotoMetadataCacheEntry],
        threshold: Float = 0.25
    ) -> [FaceCluster] {

        let items = photos.compactMap { entry -> (PhotoMetadataCacheEntry, [Float])? in
            guard let emb = entry.faceEmbedding else { return nil }
            return (entry, emb)
        }

        guard !items.isEmpty else { return [] }

        var clusters: [[PhotoMetadataCacheEntry]] = []
        var centroids: [[Float]] = []

        for (photo, embedding) in items {

            var bestIndex: Int?
            var bestDist = Float.greatestFiniteMagnitude

            for (i, centroid) in centroids.enumerated() {
                let d = cosineDistance(embedding, centroid)
                if d < bestDist {
                    bestDist = d
                    bestIndex = i
                }
            }

            if let idx = bestIndex, bestDist < threshold {
                clusters[idx].append(photo)
                centroids[idx] = averageEmbedding(clusters[idx].compactMap { $0.faceEmbedding })
            } else {
                clusters.append([photo])
                centroids.append(embedding)
            }
        }

        return clusters.enumerated().map { (i, group) in
            FaceCluster(
                photos: group,
                title: "Person \(i+1)"
            )
        }
    }
}

// MARK: Helpers

private func cosineDistance(_ a: [Float], _ b: [Float]) -> Float {
    var dot: Float = 0, normA: Float = 0, normB: Float = 0
    for i in 0..<min(a.count, b.count) {
        let x = a[i], y = b[i]
        dot += x * y
        normA += x*x
        normB += y*y
    }
    let denom = (normA.squareRoot() * normB.squareRoot())
    if denom == 0 { return 1 }
    return 1 - dot/denom
}

private func averageEmbedding(_ vectors: [[Float]]) -> [Float] {
    guard let first = vectors.first else { return [] }
    var sum = first
    for v in vectors.dropFirst() {
        for i in 0..<v.count { sum[i] += v[i] }
    }
    let c = Float(vectors.count)
    return sum.map { $0 / c }
}

extension FaceCluster {
    func asGeneratedCapsule() -> GeneratedCapsuleModel {
        GeneratedCapsuleModel(
            id: self.id.uuidString,
            name: self.title,
            coverPhoto: self.photos.first?.thumbnailFilename ?? "",
            photoCount: self.photos.count,
            photoIDs: self.photos.map { $0.id },
            generatedAt: Date()
        )
    }
}

