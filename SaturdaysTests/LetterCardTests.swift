//
//  LetterCardTests.swift
//  Saturdays
//

import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

extension LetterCard: Inspectable {}

@MainActor
struct LetterCardTests {

    @Test
    func testButtonActionIsCalled() async throws {
        var tapped = false
        let view = LetterCard {
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
