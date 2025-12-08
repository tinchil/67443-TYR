import SwiftUI
import AVKit
import Combine

struct VideoPlayerView: View {
    let url: URL
    let capsuleTitle: String?
    let capsuleDescription: String?
    let revealDate: Date?

    @State private var player: AVPlayer?
    @State private var isPlaying = true
    @State private var showOverlay = false
    @State private var cancellables = Set<AnyCancellable>()
    @State private var playerStatus: String = "Initializing..."

    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()
            LinearGradient(colors: [Color(.systemGray6), .white],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Memory Capsule")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)

                // Video player container
                ZStack {
                    if let player = player {
                        VideoPlayer(player: player)
                            .frame(height: 500)  // Explicit height
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 10)
                            .padding(.horizontal)
                            .background(Color.black)  // Add black background to see frame
                            .onTapGesture {
                                print("🎬 Video tapped")
                                togglePlayback()
                            }
                            .overlay(
                                Text("Status: \(playerStatus)")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(8)
                                    .padding(8),
                                alignment: .topLeading
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 500)
                            .overlay(
                                VStack {
                                    ProgressView()
                                    Text("Loading player...")
                                        .padding(.top, 8)
                                }
                            )
                            .padding(.horizontal)
                    }
                }

                Text("Relive your favorite memories!")
                    .font(.footnote)
                    .foregroundColor(.secondary)

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

                Spacer()
            }
            .padding(.vertical, 20)
        }
        .navigationTitle("Your Capsule Video")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            print("🛑 VideoPlayerView disappearing - cleaning up")
            player?.pause()
            player = nil
        }
    }

    private func setupPlayer() {
        print("🎬 Setting up player with URL: \(url)")
        print("🎬 URL absoluteString: \(url.absoluteString)")
        
        let playerItem = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: playerItem)
        
        // Observe player status
        playerItem.publisher(for: \.status)
            .sink { status in
                DispatchQueue.main.async {
                    switch status {
                    case .readyToPlay:
                        print("✅ AVPlayerItem is ready to play")
                        playerStatus = "Ready to play"
                    case .failed:
                        if let error = playerItem.error {
                            print("❌ AVPlayerItem failed: \(error.localizedDescription)")
                            playerStatus = "Failed: \(error.localizedDescription)"
                        }
                    case .unknown:
                        print("⏳ AVPlayerItem status unknown")
                        playerStatus = "Loading..."
                    @unknown default:
                        print("❓ AVPlayerItem unknown status")
                        playerStatus = "Unknown status"
                    }
                }
            }
            .store(in: &cancellables)
        
        self.player = newPlayer
        
        // Give it a moment to load, then play
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("▶️ Starting playback")
            newPlayer.play()
            isPlaying = true
        }
        
        print("✅ Player setup complete")
    }

    private func togglePlayback() {
        guard let player = player else { return }
        
        if isPlaying {
            print("⏸️ Pausing")
            player.pause()
        } else {
            print("▶️ Playing")
            player.play()
        }
        isPlaying.toggle()
    }
}
