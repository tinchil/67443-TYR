import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

extension VideoPlayerView: Inspectable {}

@MainActor
struct VideoPlayerViewTests {

    @Test
    func testTapTogglesPlayback() throws {
        let spy = PlayerSpy()

        let view = VideoPlayerView(
            url: URL(string: "https://example.com")!,
            capsuleTitle: nil,
            capsuleDescription: nil,
            revealDate: nil,
            makePlayer: { spy }
        )

        ViewHosting.host(view: view)
        let inspected = try view.inspect()

        // trigger .onAppear → setupPlayer()
        try inspected.callOnAppear()

        // Wait for async .play()
        RunLoop.main.run(until: Date().addingTimeInterval(0.2))

        // Find the VideoPlayer in the ZStack
        let videoPlayer = try inspected
            .find(VideoPlayer.self)

        // Tap the gesture on VideoPlayer
        try videoPlayer.callOnTapGesture()

        #expect(spy.pauseCalled == true)
    }

    @Test
    func testPlayerCreatedAndPlayed() throws {
        let spy = PlayerSpy()

        let view = VideoPlayerView(
            url: URL(string: "https://example.com")!,
            capsuleTitle: nil,
            capsuleDescription: nil,
            revealDate: nil,
            makePlayer: { spy }
        )

        // .onAppear fires automatically
        ViewHosting.host(view: view)

        // The spy must have been told to play()
        #expect(spy.playCalled == true)
    }

    @Test
    func testPlaceholderBeforeAppear() throws {
        let view = VideoPlayerView(
            url: URL(string: "https://example.com")!,
            capsuleTitle: nil,
            capsuleDescription: nil,
            revealDate: nil
        )

        ViewHosting.host(view: view)
        let inspected = try view.inspect()

        // ProgressView should appear before the AVPlayer is set
        #expect(try inspected.find(ViewType.ProgressView.self) != nil)
    }
}
