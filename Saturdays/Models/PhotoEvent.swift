//
//  PhotoEvent 2.swift
//  Saturdays
//
//  Created by Rosemary Yang on 10/26/25.
//


import Foundation
import CoreLocation

struct PhotoEvent: Identifiable {
    let id = UUID()
    let photos: [PhotoItem]
    let startDate: Date
    let endDate: Date
    let centerLocation: CLLocation?
}

class EventClusterer {
    static func cluster(
        photos: [PhotoItem],
        timeThreshold: TimeInterval = 6 * 3600,
        distanceThreshold: CLLocationDistance = 500
    ) -> [PhotoEvent] {

        guard !photos.isEmpty else { return [] }

        let sorted = photos.sorted { $0.timestamp < $1.timestamp }
        var events: [[PhotoItem]] = [[sorted[0]]]

        for photo in sorted.dropFirst() {
            guard let last = events.last?.last else { continue }

            let timeDiff = photo.timestamp.timeIntervalSince(last.timestamp)
            let distDiff = distanceBetween(photo.location, last.location)

            // NEW LOGIC: split if EITHER exceeds threshold
            if timeDiff > timeThreshold || distDiff > distanceThreshold {
                events.append([photo])
            } else {
                events[events.count - 1].append(photo)
            }
        }

        return events.map { cluster in
            let start = cluster.first!.timestamp
            let end = cluster.last!.timestamp
            let locs = cluster.compactMap { $0.location }
            let avgLoc = averageLocation(locs)
            return PhotoEvent(
                photos: cluster,
                startDate: start,
                endDate: end,
                centerLocation: avgLoc
            )
        }
    }

    private static func distanceBetween(_ a: CLLocation?, _ b: CLLocation?) -> CLLocationDistance {
        guard let a = a, let b = b else { return 0 }
        return a.distance(from: b)
    }

    private static func averageLocation(_ locs: [CLLocation]) -> CLLocation? {
        guard !locs.isEmpty else { return nil }
        let avgLat = locs.map { $0.coordinate.latitude }.reduce(0, +) / Double(locs.count)
        let avgLon = locs.map { $0.coordinate.longitude }.reduce(0, +) / Double(locs.count)
        return CLLocation(latitude: avgLat, longitude: avgLon)
    }
}

