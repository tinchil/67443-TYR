import Foundation
import Photos
import PhotosUI
import UIKit
import CoreLocation
import ImageIO
import Combine
import SwiftUI

@MainActor
class PhotoLoader: ObservableObject {
    @Published var photos: [PhotoItem] = []
    @Published var statusMessage: String = ""

    func clearPhotos() {
        photos.removeAll()
    }

    func loadPhotos(from items: [PhotosPickerItem]) {
        statusMessage = "Loading photos..."
        photos.removeAll()

        for item in items {
            item.loadTransferable(type: Data.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        guard
                            let data = data,
                            let rawImage = UIImage(data: data)
                        else {
                            print("Failed to decode image data")
                            return
                        }

                        let uiImage = rawImage.fixedOrientation()
                        var location: CLLocation?

                        // Extract GPS info (if available)
                        if let source = CGImageSourceCreateWithData(data as CFData, nil),
                           let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
                           let gps = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any],
                           let lat = gps[kCGImagePropertyGPSLatitude as String] as? Double,
                           let lon = gps[kCGImagePropertyGPSLongitude as String] as? Double,
                           let latRef = gps[kCGImagePropertyGPSLatitudeRef as String] as? String,
                           let lonRef = gps[kCGImagePropertyGPSLongitudeRef as String] as? String {

                            let finalLat = latRef == "S" ? -lat : lat
                            let finalLon = lonRef == "W" ? -lon : lon
                            location = CLLocation(latitude: finalLat, longitude: finalLon)
                            print("GPS: \(finalLat), \(finalLon)")
                        }

                        // Append photo
                        let photoItem = PhotoItem(
                            image: uiImage,
                            location: location,
                            timestamp: Date()
                        )
                        self.photos.append(photoItem)
                        self.statusMessage = "Loaded \(self.photos.count) photo(s)"
                        print("Loaded photo #\(self.photos.count)")

                    case .failure(let error):
                        self.statusMessage = "Error loading photo"
                        print("Photo load error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

// MARK: - Image Orientation Fix

extension UIImage {
    /// Normalizes image orientation so SwiftUI displays it correctly.
    func fixedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage ?? self
    }
}
