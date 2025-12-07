//
//  FaceCluster.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/7/25.
//


// FaceClusterService.swift

import Foundation

struct FaceCluster {
    let clusterID: Int
    let photoIDs: [String]
}

final class FaceClusterService {

    static let shared = FaceClusterService()
    private init() {}

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
}
