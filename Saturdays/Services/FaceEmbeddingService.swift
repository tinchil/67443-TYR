//
//  FaceEmbeddingService.swift
//  Saturdays
//
//  Face detection using Apple's Photos Framework
//  This uses the same face recognition that powers the Photos app!
//

import Foundation
import UIKit
import Photos

final class FaceEmbeddingService {

    static let shared = FaceEmbeddingService()
    private init() {}

    // MARK: - Public API

    /// Gets face identifiers from a PHAsset using iOS's native face recognition
    /// - Parameter asset: The photo asset to analyze
    /// - Returns: Array of face cluster identifiers (one per detected face)
    func getFaceIdentifiers(for asset: PHAsset) async -> [String]? {
        // Fetch faces detected by iOS Photos app
        let faces = PHAsset.fetchFaces(for: asset)

        guard faces.count > 0 else {
            print("ℹ️ No faces detected in asset \(asset.localIdentifier)")
            return nil
        }

        print("✅ Found \(faces.count) face(s) in asset")

        // Extract face cluster identifiers
        // These are unique IDs that group similar faces together
        var faceIDs: [String] = []

        faces.enumerateObjects { (face, _, _) in
            // Use faceClusteringIdentifier - this is what iOS uses to group faces
            if let clusterID = face.faceClusteringIdentifier {
                faceIDs.append(clusterID)
                print("  Face cluster ID: \(clusterID)")
            }
        }

        return faceIDs.isEmpty ? nil : faceIDs
    }

    /// Generates a simple face "embedding" by hashing face cluster IDs
    /// This allows compatibility with existing embedding-based clustering
    /// - Parameter faceIDs: Face cluster identifiers from Photos framework
    /// - Returns: A pseudo-embedding that represents the faces
    func generateEmbeddingFromFaceIDs(_ faceIDs: [String]) -> [Float] {
        // For simplicity, we'll create a 128-dimensional vector
        // by hashing the face IDs and spreading them across dimensions
        var embedding = [Float](repeating: 0, count: 128)

        for (index, faceID) in faceIDs.enumerated() {
            // Use hash of face ID to set specific dimensions
            let hash = faceID.hashValue
            let dimension = abs(hash) % 128
            embedding[dimension] = 1.0

            // Spread to nearby dimensions for smoother clustering
            if dimension > 0 {
                embedding[dimension - 1] = 0.5
            }
            if dimension < 127 {
                embedding[dimension + 1] = 0.5
            }
        }

        // Normalize the embedding
        let magnitude = sqrt(embedding.reduce(0) { $0 + $1 * $1 })
        if magnitude > 0 {
            embedding = embedding.map { $0 / magnitude }
        }

        return embedding
    }
}

// MARK: - PHAsset Extension for Face Fetching

extension PHAsset {
    static func fetchFaces(for asset: PHAsset) -> PHFetchResult<PHFace> {
        let options = PHFetchOptions()
        return PHFace.fetchFaces(in: asset, options: options)
    }
}
