// PhotoEventTests.swift
import Testing
import UIKit
import CoreLocation
import Foundation
@testable import Saturdays

struct PhotoEventTests {

    func makePhoto(timestamp: TimeInterval, lat: Double, lon: Double) -> PhotoItem {
        PhotoItem(
            image: UIImage(),
            location: CLLocation(latitude: lat, longitude: lon),
            timestamp: Date(timeIntervalSince1970: timestamp)
        )
    }

    @Test
    func testSinglePhotoEventInitialization() {
        let p = makePhoto(timestamp: 1_700_000_000, lat: 40, lon: -80)
        let e = PhotoEvent(photos: [p], startDate: p.timestamp, endDate: p.timestamp, centerLocation: p.location)

        #expect(e.photos.count == 1)
        #expect(e.startDate == e.endDate)
    }

    @Test
    func testEmptyPhotoArrayReturnsEmptyEvents() {
        #expect(EventClusterer.cluster(photos: []).isEmpty)
    }

    @Test
    func testPhotosWithinThresholdFormSingleEvent() {
        let p1 = makePhoto(timestamp: 1_700_000_000, lat: 40.0, lon: -80.0)
        let p2 = makePhoto(timestamp: 1_700_000_100, lat: 40.0008, lon: -80.0008)

        let events = EventClusterer.cluster(photos: [p1, p2], timeThreshold: 1000, distanceThreshold: 200)

        #expect(events.count == 1)
        #expect(events.first?.photos.count == 2)
    }

    @Test
    func testPhotosBeyondTimeThresholdFormSeparateEvents() {
        let p1 = makePhoto(timestamp: 1_700_000_000, lat: 40, lon: -80)
        let p2 = makePhoto(timestamp: 1_700_100_000, lat: 40, lon: -80) // 100,000 seconds apart

        // SUPER LOW threshold so split MUST happen
        let events = EventClusterer.cluster(
            photos: [p1, p2],
            timeThreshold: 1,          // 1 second
            distanceThreshold: 10_000  // allow distance, so only time matters
        )

        #expect(events.count == 2)

        if events.count == 2 {
            #expect(events[0].photos.count == 1)
            #expect(events[1].photos.count == 1)
        }
    }

    @Test
    func testPhotosBeyondDistanceThresholdFormSeparateEvents() {
        let p1 = makePhoto(timestamp: 1_700_000_000, lat: 0.0, lon: 0.0)
        let p2 = makePhoto(timestamp: 1_700_000_001, lat: 50.0, lon: 0.0) // FAR apart (thousands of km)

        // SUPER LOW distance threshold so split MUST happen
        let events = EventClusterer.cluster(
            photos: [p1, p2],
            timeThreshold: 1_000_000,  // allow time to pass
            distanceThreshold: 1        // 1 meter!
        )

        #expect(events.count == 2)

        if events.count == 2 {
            #expect(events[0].photos.count == 1)
            #expect(events[1].photos.count == 1)
        }
    }


    @Test
    func testAverageLocationCalculation() {
        let p1 = makePhoto(timestamp: 1_700_000_000, lat: 40.0, lon: -80.0)
        let p2 = makePhoto(timestamp: 1_700_000_100, lat: 41.0, lon: -79.0)

        // Large thresholds so they are forced into the same cluster
        let events = EventClusterer.cluster(
            photos: [p1, p2],
            timeThreshold: 200_000,      // >> 100s
            distanceThreshold: 1_000_000 // 1000 km, >> actual distance
        )

        #expect(events.count == 1)
        let event = events.first!

        let expectedLat = (40.0 + 41.0) / 2.0
        let expectedLon = (-80.0 + -79.0) / 2.0

        let c = event.centerLocation!.coordinate
        #expect(abs(c.latitude - expectedLat) < 0.0001)
        #expect(abs(c.longitude - expectedLon) < 0.0001)
    }


    @Test
    func testUnorderedInputStillClustersCorrectly() {
        let p1 = makePhoto(timestamp: 1_700_000_200, lat: 40.0, lon: -80.0)
        let p2 = makePhoto(timestamp: 1_700_000_000, lat: 40.001, lon: -80.001)
        let p3 = makePhoto(timestamp: 1_700_000_100, lat: 40.002, lon: -80.002)

        let events = EventClusterer.cluster(photos: [p3, p1, p2])

        #expect(events.count == 1)
        #expect(events.first?.photos.count == 3)
    }
}
