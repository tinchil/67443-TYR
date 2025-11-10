//
//  VideoPlayerView.swift
//  Saturdays
//
//  Created by Rosemary Yang on 11/10/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let url: URL
    let capsuleTitle: String?
    let capsuleDescription: String?
    let revealDate: Date?

    @State private var player = AVPlayer()
    @State private var isPlaying = true
    @State private var showOverlay = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(colors: [Color(.systemGray6), .white],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                Text("Memory Capsule")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)

                // Video player with rounded corners
                ZStack(alignment: .bottomTrailing) {
                    VideoPlayer(player: player)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 10)
                        .padding(.horizontal)
                        .onAppear {
                            player.replaceCurrentItem(with: AVPlayerItem(url: url))
                            player.play()
                            isPlaying = true
                        }
                        .onTapGesture { togglePlayback() }
                        .overlay(overlayIcon)
                }

                // Footer
                Text("Relive your favorite memories!")
                    .font(.footnote)
                    .foregroundColor(.secondary)

                // --- NEW: Capsule Details Card ---
                if let capsuleTitle = capsuleTitle {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(capsuleTitle)
                            .font(.headline)
                            .foregroundColor(.primary)

                        if let capsuleDescription = capsuleDescription {
                            Text(capsuleDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        if let revealDate = revealDate {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text("Revealed on \(revealDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 4)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 20)
        }
        .navigationTitle("Your Capsule Video")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.25), value: showOverlay)
    }

    // MARK: - Overlay
    @ViewBuilder
    private var overlayIcon: some View {
        if showOverlay {
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.white)
                .shadow(radius: 8)
                .transition(.scale)
        }
    }

    // MARK: - Toggle Playback
    private func togglePlayback() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()

        // Show temporary overlay icon
        withAnimation { showOverlay = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation { showOverlay = false }
        }
    }
}

#Preview {
    if let sampleURL = Bundle.main.url(forResource: "sample", withExtension: "mp4") {
        VideoPlayerView(
            url: sampleURL,
            capsuleTitle: "Summer in Hong Kong ☀️",
            capsuleDescription: "Weekend adventures, skyline views, and bubble tea memories.",
            revealDate: Date()
        )
    } else {
        Text("Preview not available (missing sample.mp4)")
    }
}
