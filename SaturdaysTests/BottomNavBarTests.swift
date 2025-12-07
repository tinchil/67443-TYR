//
//  BottomNavBarTests.swift
//  SaturdaysTests
//

import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

@MainActor
struct BottomNavBarTests {

    typealias AppTab = Saturdays.Tab

    @Test
    func testSelectingHomeChangesTab() throws {
        var selected: AppTab = .capsules

        let binding = Binding<AppTab>(
            get: { selected },
            set: { selected = $0 }
        )

        let view = BottomNavBar(selectedTab: binding) { }
        let inspected = try view.inspect()

        // Find the button whose label text is "Home"
        let homeButton = try inspected.find(ViewType.Button.self) { button in
            let text = try button
                .labelView()
                .find(ViewType.Text.self)
                .string()
            return text == "Home"
        }

        try homeButton.tap()
        #expect(selected == .home)
    }

    @Test
    func testSelectingCapsulesChangesTab() throws {
        var selected: AppTab = .home

        let binding = Binding<AppTab>(
            get: { selected },
            set: { selected = $0 }
        )

        let view = BottomNavBar(selectedTab: binding) { }
        let inspected = try view.inspect()

        // Find the button whose label text is "Capsules"
        let capsulesButton = try inspected.find(ViewType.Button.self) { button in
            let text = try button
                .labelView()
                .find(ViewType.Text.self)
                .string()
            return text == "Capsules"
        }

        try capsulesButton.tap()
        #expect(selected == .capsules)
    }

    @Test
    func testCreateButtonTriggersAction() throws {
        var fired = false

        let view = BottomNavBar(selectedTab: .constant(.home)) {
            fired = true
        }
        let inspected = try view.inspect()

        // Create button is the only Button whose label has NO Text (Circle + plus Image only)
        let createButton = try inspected.find(ViewType.Button.self) { button in
            (try? button.labelView().find(ViewType.Text.self)) == nil
        }

        try createButton.tap()
        #expect(fired == true)
    }

    @Test
    func testHomeLabelBoldWhenSelected() throws {
        let view = BottomNavBar(selectedTab: .constant(.home)) { }
        let inspected = try view.inspect()

        let homeText = try inspected
            .find(ViewType.Button.self) { button in
                let text = try button
                    .labelView()
                    .find(ViewType.Text.self)
                    .string()
                return text == "Home"
            }
            .labelView()
            .find(ViewType.Text.self)

        let weight = try homeText.attributes().fontWeight()
        #expect(weight == .bold)
    }

    @Test
    func testCapsulesLabelRegularWhenHomeSelected() throws {
        let view = BottomNavBar(selectedTab: .constant(.home)) { }
        let inspected = try view.inspect()

        let capsText = try inspected
            .find(ViewType.Button.self) { button in
                let text = try button
                    .labelView()
                    .find(ViewType.Text.self)
                    .string()
                return text == "Capsules"
            }
            .labelView()
            .find(ViewType.Text.self)

        let weight = try capsText.attributes().fontWeight()
        #expect(weight == .regular)
    }
}
