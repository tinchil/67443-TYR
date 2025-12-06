//
//  CapsuleDetailsViewModelTests.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/6/25.
//

import Testing
@testable import Saturdays

struct CapsuleDetailsViewModelTests {

    @Test
    func testSetGroupUpdatesState() async throws {
        let capsule = CapsuleModel(type: .memory)
        let vm = CapsuleDetailsViewModel(capsule: capsule)

        vm.setGroup(groupID: "group123", memberIDs: ["u1", "u2"])

        #expect(vm.selectedGroupID == "group123")
        #expect(vm.selectedMemberIDs == ["u1", "u2"])
        #expect(vm.capsule.groupID == "group123")
    }

    @Test
    func testInitStoresCapsule() async throws {
        let capsule = CapsuleModel(type: .letter)
        let vm = CapsuleDetailsViewModel(capsule: capsule)

        #expect(vm.capsule.type == .letter)
    }
}
