import SwiftUI
import AVKit
import Combine

struct VideoPlayerView: View {
    let url: URL
    let capsuleTitle: String?
    let capsuleDescription: String?
    let revealDate: Date?

    // TEST INJECTION
    let makePlayer: () -> AVPlayer

    @State private var player: AVPlayer?
    @State private var isPlaying = true
    @State private var cancellables = Set<AnyCancellable>()
    @State private var playerStatus: String = "Initializing..."

    init(
        url: URL,
        capsuleTitle: String?,
        capsuleDescription: String?,
        revealDate: Date?,
        makePlayer: @escaping () -> AVPlayer = { AVPlayer() }
    ) {
        self.url = url
        self.capsuleTitle = capsuleTitle
        self.capsuleDescription = capsuleDescription
        self.revealDate = revealDate
        self.makePlayer = makePlayer
    }

    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    if let player = player {
                        VideoPlayer(player: player)
                            .onTapGesture { togglePlayback() }
                            .overlay(Text("Status: \(playerStatus)"))
                    } else {
                        ProgressView()
                        Text("Loading player...")
                    }
                }

                if let capsuleTitle = capsuleTitle {
                    Text(capsuleTitle)
                }
            }
        }
        .onAppear { setupPlayer() }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }

    private func setupPlayer() {
        let newPlayer = makePlayer()
        self.player = newPlayer

        self.playerStatus = "Ready to play"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            newPlayer.play()
            isPlaying = true
        }
    }

    private func togglePlayback() {
        guard let player else { return }
        if isPlaying { player.pause() } else { player.play() }
        isPlaying.toggle()
    }
}
