//
//  PhotoMetadataExtractor.swift
//  Saturdays
//
//  Created by Rosemary Yang on 10/26/25.
//


import CoreLocation
import ImageIO
import UIKit

class PhotoMetadataExtractor {
    func extractGPS(from data: Data) -> CLLocation? {
        guard
            let source = CGImageSourceCreateWithData(data as CFData, nil),
            let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
            let gps = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any],
            let lat = gps[kCGImagePropertyGPSLatitude as String] as? Double,
            let lon = gps[kCGImagePropertyGPSLongitude as String] as? Double,
            let latRef = gps[kCGImagePropertyGPSLatitudeRef as String] as? String,
            let lonRef = gps[kCGImagePropertyGPSLongitudeRef as String] as? String
        else { return nil }

        let finalLat = latRef == "S" ? -lat : lat
        let finalLon = lonRef == "W" ? -lon : lon
        return CLLocation(latitude: finalLat, longitude: finalLon)
    }
}
