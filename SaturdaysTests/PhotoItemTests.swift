// PhotoItemTests.swift
import Testing
import UIKit
import CoreLocation
import Foundation
@testable import Saturdays

struct PhotoItemTests {

    @Test
    func testPhotoItemInitializationStoresProperties() {
        let image = UIImage(systemName: "photo")!
        let location = CLLocation(latitude: 40.0, longitude: -80.0)
        let timestamp = Date(timeIntervalSince1970: 1_700_000_000)

        let item = PhotoItem(
            image: image,
            location: location,
            timestamp: timestamp
        )

        #expect(item.location?.coordinate.latitude == 40.0)
        #expect(item.location?.coordinate.longitude == -80.0)
        #expect(item.timestamp == timestamp)
    }

    @Test
    func testPhotoItemIDIsUniquePerInstance() {
        let i1 = PhotoItem(image: UIImage(), location: nil, timestamp: Date())
        let i2 = PhotoItem(image: UIImage(), location: nil, timestamp: Date())

        #expect(i1.id != i2.id)
    }

    @Test
    func testPhotoItemCanHaveNoLocation() {
        let item = PhotoItem(
            image: UIImage(systemName: "photo")!,
            location: nil,
            timestamp: Date(timeIntervalSince1970: 1_700_000_100)
        )

        #expect(item.location == nil)
    }
}
