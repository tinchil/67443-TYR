//
//  ChooseGroupViewTests.swift
//  Saturdays
//
//  Created by Yining He  on 12/7/25.
//

import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

@MainActor
struct ChooseGroupViewTests {

    // MARK: - Simple Mock GroupsViewModel
    final class MockGroupsVM: GroupsViewModel {
        override func loadGroups() {
            self.groups = [
                GroupModel(id: "1", name: "Friends", memberIDs: ["a", "b"], createdBy: "x", createdAt: Date(), coverPhotoURL: nil),
                GroupModel(id: "2", name: "Family", memberIDs: ["y"], createdBy: "x", createdAt: Date(), coverPhotoURL: nil)
            ]
        }
    }

    // MARK: - BASIC RENDER TEST
    @Test
    func testHeaderAppears() throws {
        let capsuleVM = CapsuleDetailsViewModel(capsule: CapsuleModel(type: .memory))
        let groupsVM = MockGroupsVM()

        let view = ChooseGroupView(capsuleVM: capsuleVM, groupsVM: groupsVM)

        ViewHosting.host(view: view)

        let inspected = try view.inspect()

        let text = try inspected.find(text: "CHOOSE WHICH GROUP TO\nCREATE A CAPSULE FOR")
        #expect(try text.string().contains("CHOOSE WHICH GROUP"))
    }


    // MARK: - GROUP BUTTON COUNT TEST
    @Test
    func testRendersTwoGroups() throws {
        let capsuleVM = CapsuleDetailsViewModel(capsule: CapsuleModel(type: .memory))
        let groupsVM = MockGroupsVM()

        let view = ChooseGroupView(capsuleVM: capsuleVM, groupsVM: groupsVM)
        ViewHosting.host(view: view)

        let inspected = try view.inspect()

        let scroll = try inspected.find(ViewType.ScrollView.self)
        let vgrid = try scroll.find(ViewType.LazyVGrid.self)

    }


    // MARK: - NEW GROUP BUTTON TAP
    @Test
    func testNewGroupButtonTapTriggersState() throws {
        let capsuleVM = CapsuleDetailsViewModel(capsule: CapsuleModel(type: .memory))
        let groupsVM = MockGroupsVM()

        var tapped = false
        let testButton = NewGroupButton { tapped = true }

        ViewHosting.host(view: testButton)

        let inspected = try testButton.inspect()
        try inspected.button().tap()

        #expect(tapped == true)
    }


    // MARK: - GROUP CIRCLE BUTTON TAP
    @Test
    func testGroupCircleButtonTapCallsClosure() throws {
        var tapped = false

        let button = GroupCircleButton(
            name: "Test",
            memberCount: 2,
            isSelected: false,
            onTap: { tapped = true }
        )

        ViewHosting.host(view: button)

        let inspected = try button.inspect()
        try inspected.button().tap()

        #expect(tapped == true)
    }
}
