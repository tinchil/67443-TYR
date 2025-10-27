import Foundation
import PhotosUI
import UIKit
import CoreLocation
import Combine
import SwiftUI

@MainActor
class PhotoLoader: ObservableObject {
    @Published var photos: [PhotoItem] = []
    @Published var statusMessage: String = ""
    
    private let metadataExtractor = PhotoMetadataExtractor()

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
                        guard let data, let image = UIImage(data: data)?.fixedOrientation() else {
                            self.statusMessage = "Failed to decode image"
                            return
                        }

                        let location = self.metadataExtractor.extractGPS(from: data)
                        let photo = PhotoItem(image: image, location: location, timestamp: Date())
                        self.photos.append(photo)
                        self.statusMessage = "Loaded \(self.photos.count) photo(s)"

                    case .failure(let error):
                        self.statusMessage = "Error loading photo: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}
