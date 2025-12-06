//
//  CapsuleCardViewTests.swift
//  Saturdays
//

import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

@MainActor
struct CapsuleCardViewTests {

    @Test
    func testShowsUntitledWhenEmpty() async throws {
        var model = CapsuleModel(type: .memory)
        model.name = ""

        let view = CapsuleCardView(capsule: model)

        try await ViewHosting.host(view) { hosted in
            let inspected = try hosted.inspect()
            let text = try inspected.find(text: "Untitled Capsule")
            #expect(text != nil)
        }
    }

    @Test
    func testShowsNameWhenProvided() async throws {
        var model = CapsuleModel(type: .memory)
        model.name = "Trip"

        let view = CapsuleCardView(capsule: model)

        try await ViewHosting.host(view) { hosted in
            let inspected = try hosted.inspect()
            let text = try inspected.find(text: "Trip")
            #expect(text != nil)
        }
    }
}
