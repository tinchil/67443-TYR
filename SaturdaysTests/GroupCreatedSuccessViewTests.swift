//
//  GroupCreatedSuccessViewTests.swift
//  Saturdays
//
//  Created by Yining He  on 12/6/25.
//

import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

@MainActor
struct GroupCreatedSuccessViewTests {

    // Helper capsuleVM
    func makeCapsuleVM() -> CapsuleDetailsViewModel {
        CapsuleDetailsViewModel(capsule: CapsuleModel(type: .memory))
    }

    @Test
    func testRendersSuccessText() throws {
        let vm = makeCapsuleVM()
        let view = GroupCreatedSuccessView(capsuleVM: vm)

        ViewHosting.host(view: view)

        let inspected = try view.inspect()
        let text = try inspected.find(text: "Group Created!")
        #expect(try text.string() == "Group Created!")
    }

    @Test
    func testCheckmarkImageExists() throws {
        let vm = makeCapsuleVM()
        let view = GroupCreatedSuccessView(capsuleVM: vm)

        ViewHosting.host(view: view)
        let inspected = try view.inspect()

        // find the SF Symbol
        let image = try inspected.find(ViewType.Image.self)
        #expect(try image.actualImage().name() == "checkmark")
    }}
