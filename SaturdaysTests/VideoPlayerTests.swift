//
//  VideoPlayerTests.swift
//  Saturdays
//
//  Created by Yining He  on 12/7/25.
//

import Testing
import SwiftUI
@testable import Saturdays

@MainActor
struct VideoPlayerTests {

    @Test
    func testVideoPlayerInitializerStoresValues() throws {
        let url = URL(string: "https://example.com/video.mp4")!
        let title = "Test Title"
        let desc = "Test Description"
        let date = Date()

        let view = VideoPlayerView(
            url: url,
            capsuleTitle: title,
            capsuleDescription: desc,
            revealDate: date
        )

        #expect(view.url == url)
        #expect(view.capsuleTitle == title)
        #expect(view.capsuleDescription == desc)
        #expect(view.revealDate == date)
    }

    @Test
    func testVideoPlayerViewIsUIViewControllerRepresentable() throws {
        // We cannot call makeUIViewController() because context cannot be created.
        // But we CAN assert protocol conformance.
        let view = VideoPlayerView(
            url: URL(string:"https://example.com/video.mp4")!,
            capsuleTitle: "A",
            capsuleDescription: "B",
            revealDate: .now
        )

        // Check conformance
        #expect(view is UIViewControllerRepresentable)
    }

    @Test
    func testVideoPlayerViewTypeInfo() throws {
        // A simple structural reflection test
        let mirror = Mirror(reflecting: VideoPlayerView.self)

        // The type should be a struct
        #expect(mirror.displayStyle == .struct)
    }
}
