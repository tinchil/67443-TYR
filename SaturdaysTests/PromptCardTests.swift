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
    func testDisplaysPrompt() throws {
        let view = PromptCard(prompt: "Hello world")

        ViewHosting.host(view: view)

        let inspected = try view.inspect()
        let text = try inspected.find(text: "Hello world").string()

        #expect(text == "Hello world")
    }

    @Test
    func testEditButtonExists() throws {
        let view = PromptCard(prompt: "Sample")

        ViewHosting.host(view: view)

        let inspected = try view.inspect()

        // This succeeds if button exists; it throws if not found
        _ = try inspected.find(ViewType.Button.self)

        #expect(true)  // If we reached here, the button exists
    }
}
