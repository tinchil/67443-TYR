//
//  PromptCardTests.swift
//  Saturdays
//

import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

@MainActor
struct PromptCardTests {

    @Test
    func testDisplaysPrompt() async throws {
        let view = PromptCard(prompt: "Hello world")

        try await ViewHosting.host(view) { hosted in
            let inspected = try hosted.inspect()
            let text = try inspected.find(text: "Hello world").string()
            #expect(text == "Hello world")
        }
    }

    @Test
    func testEditButtonExists() async throws {
        let view = PromptCard(prompt: "Sample")

        try await ViewHosting.host(view) { hosted in
            let inspected = try hosted.inspect()

            let button = try inspected.find(ViewType.Button.self)
            #expect(button != nil)
        }
    }
}
