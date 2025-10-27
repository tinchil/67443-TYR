import SwiftUI
import PhotosUI
import AVKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var photoLoader = PhotoLoader()
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isCreatingVideo = false
    @State private var videoURL: URL?
    @State private var showVideoPlayer = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                // Status message
                if !photoLoader.statusMessage.isEmpty {
                    Text(photoLoader.statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Event-based grid view
                if !photoLoader.events.isEmpty {
                    ScrollView {
                        ForEach(photoLoader.events) { event in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("📅 \(event.startDate.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.headline)
                                    if let loc = event.centerLocation {
                                        Text("• \(String(format: "%.4f", loc.coordinate.latitude)), \(String(format: "%.4f", loc.coordinate.longitude))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal)

                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                                    ForEach(event.photos) { photo in
                                        Image(uiImage: photo.image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.bottom, 12)
                        }
                        .padding(.horizontal)
                    }
                } else if !photoLoader.photos.isEmpty {
                    // Fallback: single event (no GPS metadata)
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(photoLoader.photos) { photo in
                                Image(uiImage: photo.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                    }
                }

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 50,
                        matching: .images
                    ) {
                        Label("Select Photos", systemImage: "photo.on.rectangle.angled")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    if !photoLoader.photos.isEmpty {
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

                        Button(role: .destructive) {
                            photoLoader.clearPhotos()
                        } label: {
                            Label("Clear All", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Saturdays POC")
            .onAppear {
                locationManager.requestPermission()
                locationManager.startUpdating()
            }
            .onChange(of: selectedItems) { newItems in
                Task { await photoLoader.loadPhotos(from: newItems) }
            }
            .sheet(isPresented: $showVideoPlayer) {
                if let url = videoURL {
                    VideoPlayerView(url: url)
                }
            }
        }
    }

    // MARK: - Video Creation
    private func createVideo() {
        isCreatingVideo = true
        photoLoader.statusMessage = "Creating video compilation..."

        VideoCreator.createVideo(from: photoLoader.photos) { url in
            isCreatingVideo = false
            if let url = url {
                videoURL = url
                showVideoPlayer = true
                photoLoader.statusMessage = "Video created successfully!"
            } else {
                photoLoader.statusMessage = "Failed to create video."
            }
        }
    }
}
