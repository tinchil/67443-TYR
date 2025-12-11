//
//  MainTabViewTests.swift
//  SaturdaysTests
//

import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

extension MainTabView: Inspectable {}
extension BottomNavBar: Inspectable {}

@MainActor
struct MainTabViewTests {

    // ---------------------------------------------------------
    // 1. Tapping “Capsules” changes selectedTab via Binding
    // ---------------------------------------------------------
    @Test
    func testTabSwitchToCapsules() throws {
        var tab: Saturdays.Tab = .home
        var overlay = false

        let view = MainTabView(
            selectedTab: Binding(
                get: { tab },
                set: { tab = $0 }
            ),
            showCreateOverlay: Binding(
                get: { overlay },
                set: { overlay = $0 }
            )
        )

        ViewHosting.host(view: view)
        let inspected = try view.inspect()

        let nav = try inspected.find(BottomNavBar.self)

        // Find the button whose label contains "Capsules"
        let capsulesButton = try nav.find(ViewType.Button.self) { button in
            (try? button.labelView().find(text: "Capsules")) != nil
        }

        try capsulesButton.tap()

        #expect(tab == .capsules)
    }

    // ---------------------------------------------------------
    // 2. Overlay dismiss tap sets showCreateOverlay = false
    // ---------------------------------------------------------
    @Test
    func testOverlayDismissTap() throws {
        var tab: Saturdays.Tab = .home
        var overlay = true

        let view = MainTabView(
            selectedTab: Binding(
                get: { tab },
                set: { tab = $0 }
            ),
            showCreateOverlay: Binding(
                get: { overlay },
                set: { overlay = $0 }
            )
        )

        ViewHosting.host(view: view)
        let inspected = try view.inspect()

        // 1. Find the ZStack inside NavigationStack
        let zstack = try inspected
            .find(ViewType.ZStack.self)

        // 2. Find the dimming background by matching the onTapGesture
        let bg = try zstack.find(ViewType.Color.self) { color in
            // The ONLY Color with a tap gesture is the dim overlay
            (try? color.callOnTapGesture()) != nil
        }

        // 3. Perform tap
        try bg.callOnTapGesture()

        // 4. Assert overlay turned off
        #expect(overlay == false)
    }

}
