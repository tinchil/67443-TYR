import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

extension BottomNavBar: Inspectable {}

struct BottomNavBarTests {

    @Test
    func testSelectingHomeChangesTab() async throws {
        var selected: Tab = .capsules

        let view = BottomNavBar(selectedTab: .constant(selected)) { }
        let inspected = try view.inspect()

        try inspected.find(text: "Home").parent().tap()

        // re-inspect binding
        let newValue = try inspected.actualView().selectedTab
        #expect(newValue == .home)
    }

    @Test
    func testSelectingCapsulesChangesTab() async throws {
        var selected: Tab = .home

        let view = BottomNavBar(selectedTab: .constant(selected)) { }
        let inspected = try view.inspect()

        try inspected.find(text: "Capsules").parent().tap()
        let newValue = try inspected.actualView().selectedTab
        #expect(newValue == .capsules)
    }

    @Test
    func testCreateActionIsCalled() async throws {
        var didCreate = false

        let view = BottomNavBar(selectedTab: .constant(.home)) {
            didCreate = true
        }

        let inspected = try view.inspect()

        let createButton = try inspected.find(ViewType.Button.self).where { btn in
            try? btn.find(text: "Home") == nil &&
            try? btn.find(text: "Capsules") == nil
        }

        try createButton.tap()
        #expect(didCreate == true)
    }
}
