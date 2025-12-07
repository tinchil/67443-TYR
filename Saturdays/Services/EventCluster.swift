//
//  EventCluster.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/7/25.
//


// EventClusterService.swift

import Foundation

struct EventCluster {
    let id = UUID()
    let photos: [PhotoMetadataCacheEntry]
    let title: String
}

final class EventClusterService {

    static let shared = EventClusterService()
    private init() {}

    /// Hardcoded: Break last 20 photos into 3 events.
    func clusterEventsHardcoded(from photos: [PhotoMetadataCacheEntry]) -> [EventCluster] {

        let last20 = Array(photos.suffix(20))
        print("🧭 [EventCluster] Hardcoded event clustering over \(last20.count) photos")

        let chunked = last20.chunked(into: max(1, last20.count / 3))

        var events: [EventCluster] = []
        for (i, group) in chunked.enumerated() {
            print("🧭 [EventCluster] Event \(i+1): \(group.count) photos")
            events.append(EventCluster(photos: group, title: "Event \(i+1)"))
        }

        return events
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
