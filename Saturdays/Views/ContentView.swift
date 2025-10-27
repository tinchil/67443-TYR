import SwiftUI
import PhotosUI
import AVKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var photoLoader = PhotoLoader()
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isCreatingVideoFor: UUID? = nil
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
                                    Spacer()

                                    // Per-event video button
                                    Button {
                                        createVideo(for: event)
                                    } label: {
                                        HStack(spacing: 4) {
                                            if isCreatingVideoFor == event.id {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            } else {
                                                Image(systemName: "video.badge.plus")
                                            }
                                            Text("Create Video")
                                                .font(.caption)
                                                .bold()
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(isCreatingVideoFor == event.id ? Color.gray : Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                    }
                                    .disabled(isCreatingVideoFor != nil)
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
                    // Fallback: single grid when clustering not available
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

    // MARK: - Create Video for a Single Event
    private func createVideo(for event: PhotoEvent) {
        isCreatingVideoFor = event.id
        photoLoader.statusMessage = "Creating video for event..."

        VideoCreator.createVideo(from: event.photos) { url in
            isCreatingVideoFor = nil
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
