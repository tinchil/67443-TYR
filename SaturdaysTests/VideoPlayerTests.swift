//
//  VideoPlayerViewTests.swift
//

import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

extension VideoPlayerView: Inspectable {}

@MainActor
struct VideoPlayerViewTests {
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

        ViewHosting.host(view: view)

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

        #expect(try inspected.find(ViewType.ProgressView.self) != nil)
    }
}
