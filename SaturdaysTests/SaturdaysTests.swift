// SaturdaysSmokeTests.swift
import Testing
import Foundation
@testable import Saturdays

struct SaturdaysSmokeTests {

    @Test
    func testCanConstructBasicGraphOfModels() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        let user = UserModel(
            id: "user-1",
            username: "@user1",
            displayName: "User One",
            email: "user1@example.com",
            createdAt: now
        )

        let group = GroupModel(
            id: "group-1",
            name: "Test Group",
            memberIDs: [user.id],
            createdBy: user.id,
            createdAt: now,
            coverPhotoURL: nil
        )

        let capsule = CapsuleModel(
            name: "Test Capsule",
            type: .memory,
            groupID: group.id,
            coverPhoto: nil
        )

        #expect(group.memberIDs.contains(user.id))
        #expect(capsule.groupID == group.id)
        #expect(capsule.type == .memory)
    }
}
