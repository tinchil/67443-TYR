//
//  EventCluster.swift
//  Saturdays
//

import Foundation
import CoreLocation

struct EventCluster {
    let id = UUID()
    let photos: [PhotoMetadataCacheEntry]
    let title: String
}

final class EventClusterService {

    static let shared = EventClusterService()
    private init() {}

    /// Real event clustering:
    /// Groups photos into events based on time and location proximity.
    func clusterEventsHardcoded(
        from photos: [PhotoMetadataCacheEntry],
        timeThreshold: TimeInterval = 6 * 3600,       // 6 hours
        distanceThreshold: CLLocationDistance = 500   // 500 meters
    ) -> [EventCluster] {

        guard !photos.isEmpty else { return [] }

        // Sort oldest → newest
        let sorted = photos.sorted { $0.timestamp < $1.timestamp }

        print("🧭 [EventCluster] Running real event clustering over \(sorted.count) photos")

        var clusters: [[PhotoMetadataCacheEntry]] = [[sorted[0]]]

        for photo in sorted.dropFirst() {
            guard let last = clusters.last?.last else { continue }

            let timeDiff = photo.timestamp.timeIntervalSince(last.timestamp)
            let distDiff = distanceBetween(photo.location, last.location)

            // Start a NEW event if either threshold is exceeded
            if timeDiff > timeThreshold || distDiff > distanceThreshold {
                clusters.append([photo])
            } else {
                clusters[clusters.count - 1].append(photo)
            }
        }

        print("🧭 [EventCluster] Formed \(clusters.count) raw events")

        // Convert to EventCluster with titles
        let eventClusters: [EventCluster] = clusters.enumerated().map { (index, group) in
            let start = group.first?.timestamp ?? Date()
            let title = formattedEventDate(start, index: index)
            print("🧭 [EventCluster] Event \(index+1): \(group.count) photos")
            return EventCluster(photos: group, title: title)
        }

        return eventClusters
    }

    // MARK: - Helpers

    private func distanceBetween(_ a: CLLocation?, _ b: CLLocation?) -> CLLocationDistance {
        guard let a = a, let b = b else { return 0 }
        return a.distance(from: b)
    }

    private func formattedEventDate(_ date: Date, index: Int) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return "Event \(index + 1) • \(f.string(from: date))"
    }
}
