import Foundation
import UIKit
import Vision
import Photos

final class FaceEmbeddingService {

    static let shared = FaceEmbeddingService()
    private init() {}

    // MARK: - Public API

    /// Detects faces in a PHAsset and returns stable string IDs
    func getFaceIdentifiers(for asset: PHAsset) async -> [String]? {
        // Load UIImage from the Photos asset
        guard let uiImage = await loadImage(from: asset),
              let cgImage = uiImage.cgImage else {
            print("❌ Failed to load image for face detection.")
            return nil
        }

        // Run Vision synchronously (no async / Sendable issues)
        let faceObservations = detectFaces(in: cgImage)

        guard !faceObservations.isEmpty else {
            print("ℹ️ No faces detected in asset \(asset.localIdentifier)")
            return nil
        }

        print("✅ Found \(faceObservations.count) face(s)")

        // Turn each bounding box into a stable ID string
        let ids: [String] = faceObservations.map { obs in
            let rectString = NSCoder.string(for: obs.boundingBox)
            return "vision_face_" + String(rectString.hashValue)
        }

        return ids
    }

    /// Same embedding function you had before, just reused
    func generateEmbeddingFromFaceIDs(_ faceIDs: [String]) -> [Float] {
        var embedding = [Float](repeating: 0, count: 128)

        for faceID in faceIDs {
            let h = abs(faceID.hashValue)
            let idx = h % 128
            embedding[idx] = 1.0
            if idx > 0   { embedding[idx - 1] = 0.5 }
            if idx < 127 { embedding[idx + 1] = 0.5 }
        }

        let magnitude = sqrt(embedding.reduce(0) { $0 + $1 * $1 })
        return magnitude == 0 ? embedding : embedding.map { $0 / magnitude }
    }
}

// MARK: - Helpers

extension FaceEmbeddingService {

    /// Async wrapper around PHImageManager to get a UIImage
    private func loadImage(from asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = false

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }

    /// Synchronous Vision face detection (no Sendable warnings)
    private func detectFaces(in cgImage: CGImage) -> [VNFaceObservation] {
        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
            return request.results as? [VNFaceObservation] ?? []
        } catch {
            print("❌ Vision face detection error:", error)
            return []
        }
    }
}
