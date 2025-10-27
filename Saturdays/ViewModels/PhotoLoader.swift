import Foundation
import PhotosUI
import UIKit
import CoreLocation
import Combine
import SwiftUI

@MainActor
class PhotoLoader: ObservableObject {
    @Published var photos: [PhotoItem] = []
    @Published var events: [PhotoEvent] = []
    @Published var statusMessage: String = ""
    
    private let metadataExtractor = PhotoMetadataExtractor()

    func clearPhotos() {
        photos.removeAll()
        events.removeAll()
    }

    func loadPhotos(from items: [PhotosPickerItem]) {
        statusMessage = "Loading photos..."
        photos.removeAll()
        events.removeAll()

        let group = DispatchGroup()

        for item in items {
            group.enter()
            item.loadTransferable(type: Data.self) { result in
                DispatchQueue.main.async {
                    defer { group.leave() }
                    switch result {
                    case .success(let data):
                        guard let data, let image = UIImage(data: data)?.fixedOrientation() else {
                            self.statusMessage = "Failed to decode image"
                            return
                        }

                        let location = self.metadataExtractor.extractGPS(from: data)
                        let timestamp = self.metadataExtractor.extractDate(from: data) ?? Date()
                        let photo = PhotoItem(image: image, location: location, timestamp: timestamp)
                        self.photos.append(photo)
                        self.statusMessage = "Loaded \(self.photos.count) photo(s)"

                    case .failure(let error):
                        self.statusMessage = "Error loading photo: \(error.localizedDescription)"
                    }
                }
            }
        }

        // Wait until all photos are processed, then cluster
        group.notify(queue: .main) {
            self.clusterEvents()
        }
    }

    // MARK: - Event Clustering
    private func clusterEvents() {
        events = EventClusterer.cluster(photos: photos)
        if events.isEmpty {
            statusMessage = "No events detected."
        } else {
            statusMessage = "Grouped into \(events.count) event(s)"
        }
    }
}
