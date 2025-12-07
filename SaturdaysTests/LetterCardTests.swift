//
//  LetterCardTests.swift
//  Saturdays
//

import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

@MainActor
struct LetterCardTests {

    @Test
    func testButtonActionIsCalled() throws {
        var tapped = false

        let view = LetterCard {
            tapped = true
        }

        // Host the view (non-async, non-throwing)
        ViewHosting.host(view: view)

        // Inspect the hosted view
        let inspected = try view.inspect()

        // Find the button and tap it
        let button = try inspected.find(ViewType.Button.self)
        try button.tap()

        #expect(tapped == true)
    }
}
