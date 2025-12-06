//
//  MemoryCardTests.swift
//  Saturdays
//

import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

@MainActor
struct MemoryCardTests {

    @Test
    func testButtonActionIsCalled() throws {
        var tapped = false

        let view = MemoryCard {
            tapped = true
        }

        // Host view (sync, no throwing)
        ViewHosting.host(view: view)

        // Inspect hosted view
        let inspected = try view.inspect()

        // Find button and tap
        let button = try inspected.find(ViewType.Button.self)
        try button.tap()

        #expect(tapped == true)
    }
}
