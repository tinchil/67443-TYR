//
//  MemoryCardTests.swift
//  Saturdays
//

import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

extension MemoryCard: Inspectable {}

@MainActor
struct MemoryCardTests {

    @Test
    func testButtonActionIsCalled() async throws {
        var tapped = false
        let view = MemoryCard {
            tapped = true
        }

        try await ViewHosting.host(view) { hosted in
            let inspected = try hosted.inspect()

            let button = try inspected.find(ViewType.Button.self)
            try button.tap()

            #expect(tapped == true)
        }
    }
}
