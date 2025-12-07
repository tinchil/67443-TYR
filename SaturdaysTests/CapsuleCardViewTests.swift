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
    func testShowsUntitledWhenEmpty() throws {
        var model = CapsuleModel(type: .memory)
        model.name = ""

        let view = CapsuleCardView(capsule: model)

        // host is NOT async and does NOT throw
        ViewHosting.host(view: view)

        // inspect DOES throw
        let inspected = try view.inspect()

        let text = try inspected.find(text: "Untitled Capsule")
        #expect(try text.string() == "Untitled Capsule")
    }

    @Test
   func testShowsNameWhenProvided() throws {
        var model = CapsuleModel(type: .memory)
        model.name = "Trip"

        let view = CapsuleCardView(capsule: model)

        ViewHosting.host(view: view)

        let inspected = try view.inspect()
        let text = try inspected.find(text: "Trip")
        #expect(try text.string() == "Trip")
    }
}
