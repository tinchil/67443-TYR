//
//  PhotoEventTests.swift
//  SaturdaysTests
//
//  Created by Yining He  on 11/10/25.
//

import Testing
import CoreLocation
import UIKit
@testable import Saturdays

struct PhotoEventTests {
    
    // MARK: - Helper function to create fake PhotoItems
    func makePhotoItem(timestamp: Date, lat: Double, lon: Double) -> PhotoItem {
        return PhotoItem(
            image: UIImage(systemName: "photo")!,
            location: CLLocation(latitude: lat, longitude: lon),
            timestamp: timestamp
        )
    }

    // MARK: - PhotoEvent Initialization Tests
    
    @Test func testSinglePhotoEventInitialization() throws {
        let now = Date()
        let photo = makePhotoItem(timestamp: now, lat: 40.0, lon: -80.0)
        let event = PhotoEvent(
            photos: [photo],
            startDate: now,
            endDate: now,
            centerLocation: photo.location
        )
        
        #expect(event.photos.count == 1)
        #expect(event.startDate == event.endDate)
        #expect(event.centerLocation?.coordinate.latitude == 40.0)
        #expect(event.centerLocation?.coordinate.longitude == -80.0)
    }

    // MARK: - Clusterer: Edge Cases
    
    @Test func testEmptyPhotoArrayReturnsEmptyEvents() throws {
        let result = EventClusterer.cluster(photos: [])
        #expect(result.isEmpty)
    }

    // MARK: - Clusterer: Time and Distance Logic
    
    @Test func testPhotosWithinThresholdFormSingleEvent() throws {
        let now = Date()
        let p1 = makePhotoItem(timestamp: now, lat: 40.0, lon: -80.0)
        let p2 = makePhotoItem(timestamp: now.addingTimeInterval(3600), lat: 40.001, lon: -80.001)
        
        let events = EventClusterer.cluster(photos: [p1, p2])
        
        #expect(events.count == 1)
        #expect(events.first?.photos.count == 2)
        #expect(events.first?.startDate == p1.timestamp)
        #expect(events.first?.endDate == p2.timestamp)
    }

    @Test func testPhotosBeyondTimeThresholdFormSeparateEvents() throws {
        let now = Date()
        let p1 = makePhotoItem(timestamp: now, lat: 40.0, lon: -80.0)
        let p2 = makePhotoItem(timestamp: now.addingTimeInterval(8 * 3600), lat: 40.0, lon: -80.0) // 8 hours later
        
        let events = EventClusterer.cluster(photos: [p1, p2], timeThreshold: 6 * 3600)
        
        #expect(events.count == 2)
        #expect(events[0].photos.count == 1)
        #expect(events[1].photos.count == 1)
    }

    @Test func testPhotosBeyondDistanceThresholdFormSeparateEvents() throws {
        let now = Date()
        let p1 = makePhotoItem(timestamp: now, lat: 40.0, lon: -80.0)
        let p2 = makePhotoItem(timestamp: now.addingTimeInterval(1000), lat: 41.0, lon: -81.0) // ~140km apart
        
        let events = EventClusterer.cluster(photos: [p1, p2], distanceThreshold: 500)
        
        #expect(events.count == 2)
    }

    // MARK: - Clusterer: Location Logic
    
    @Test func testAverageLocationCalculation() throws {
        let now = Date()
        let p1 = makePhotoItem(timestamp: now, lat: 40.0, lon: -80.0)
        let p2 = makePhotoItem(timestamp: now.addingTimeInterval(60), lat: 41.0, lon: -79.0)
        
        let events = EventClusterer.cluster(photos: [p1, p2])
        let avgLat = (40.0 + 41.0) / 2.0
        let avgLon = (-80.0 + -79.0) / 2.0
        
        #expect(abs((events.first?.centerLocation?.coordinate.latitude ?? 0) - avgLat) < 0.0001)
        #expect(abs((events.first?.centerLocation?.coordinate.longitude ?? 0) - avgLon) < 0.0001)
    }

    // MARK: - Clusterer: Sorting Behavior
    
    @Test func testUnorderedInputStillClustersCorrectly() throws {
        let now = Date()
        let p1 = makePhotoItem(timestamp: now.addingTimeInterval(100), lat: 40.0, lon: -80.0)
        let p2 = makePhotoItem(timestamp: now, lat: 40.001, lon: -80.001)
        let p3 = makePhotoItem(timestamp: now.addingTimeInterval(200), lat: 40.002, lon: -80.002)
        
        // Input intentionally unsorted
        let events = EventClusterer.cluster(photos: [p3, p1, p2])
        
        #expect(events.count == 1)
        #expect(events.first?.photos.count == 3)
        #expect(events.first?.startDate <= events.first!.endDate)
    }
}
