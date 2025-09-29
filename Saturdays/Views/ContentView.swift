import SwiftUI
import PhotosUI
import AVKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var photos: [PhotoItem] = []
    @State private var isCreatingVideo = false
    @State private var videoURL: URL?
    @State private var showVideoPlayer = false
    @State private var statusMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Status
                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                // Photo Grid
                if !photos.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(photos) { photo in
                                VStack {
                                    Image(uiImage: photo.image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .cornerRadius(8)
                                    
                                    if let location = photo.location {
                                        Text("📍 \(String(format: "%.4f", location.coordinate.latitude)), \(String(format: "%.4f", location.coordinate.longitude))")
                                            .font(.caption2)
                                            .lineLimit(1)
                                    } else {
                                        Text("No location")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
                
                // Buttons
                VStack(spacing: 15) {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        Label("Select Photos", systemImage: "photo.on.rectangle.angled")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    if !photos.isEmpty {
                        Button(action: createVideo) {
                            HStack {
                                if isCreatingVideo {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Label("Create Video", systemImage: "video.badge.plus")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isCreatingVideo ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(isCreatingVideo)
                        
                        Button(action: { photos.removeAll() }) {
                            Label("Clear All", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Saturdays POC")
            .onAppear {
                locationManager.requestPermission()
                locationManager.startUpdating()
            }
            .onChange(of: selectedItems) { newItems in
                loadPhotos(from: newItems)
            }
            .sheet(isPresented: $showVideoPlayer) {
                if let url = videoURL {
                    VideoPlayerView(url: url)
                }
            }
        }
    }
    
    private func loadPhotos(from items: [PhotosPickerItem]) {
        statusMessage = "Loading photos..."
        
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let data = data, let uiImage = UIImage(data: data) {
                            let photoItem = PhotoItem(
                                image: uiImage,
                                location: locationManager.currentLocation,
                                timestamp: Date()
                            )
                            photos.append(photoItem)
                            statusMessage = "Loaded \(photos.count) photo(s)"
                        }
                    case .failure(let error):
                        statusMessage = "Error loading photo: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    private func createVideo() {
        isCreatingVideo = true
        statusMessage = "Creating video compilation..."
        
        VideoCreator.createVideo(from: photos) { url in
            DispatchQueue.main.async {
                isCreatingVideo = false
                if let url = url {
                    videoURL = url
                    showVideoPlayer = true
                    statusMessage = "Video created successfully!"
                } else {
                    statusMessage = "Failed to create video"
                }
            }
        }
    }
}
