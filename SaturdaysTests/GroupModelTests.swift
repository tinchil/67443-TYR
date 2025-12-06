//  GroupModelTests.swift
//  SaturdaysTests

import Testing
import Foundation
@testable import Saturdays

struct GroupModelTests {

    @Test
    func testGroupModelInitialization() {
        let now = Date()
        let group = GroupModel(
            id: "group-1",
            name: "CMU Crew",
            memberIDs: ["user-1", "user-2"],
            createdBy: "user-1",
            createdAt: now,
            coverPhotoURL: "https://example.com/cover.jpg"
        )

        #expect(group.id == "group-1")
        #expect(group.name == "CMU Crew")
        #expect(group.memberIDs.count == 2)
        #expect(group.createdBy == "user-1")
        #expect(group.createdAt == now)
        #expect(group.coverPhotoURL == "https://example.com/cover.jpg")
    }

    @Test
    func testGroupModelCanHaveNoCoverPhoto() {
        let group = GroupModel(
            id: "group-2",
            name: "No Cover Group",
            memberIDs: [],
            createdBy: "creator",
            createdAt: Date(),
            coverPhotoURL: nil
        )

        #expect(group.coverPhotoURL == nil)
        #expect(group.memberIDs.isEmpty)
    }

    @Test
    func testGroupModelCodableRoundTrip() throws {
        let group = GroupModel(
            id: "group-3",
            name: "Travel Buddies",
            memberIDs: ["u1", "u2", "u3"],
            createdBy: "u1",
            createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            coverPhotoURL: "https://example.com/travel.jpg"
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(group)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(GroupModel.self, from: data)

        #expect(decoded.id == group.id)
        #expect(decoded.name == group.name)
        #expect(decoded.memberIDs == group.memberIDs)
        #expect(decoded.createdBy == group.createdBy)
        #expect(decoded.createdAt == group.createdAt)
        #expect(decoded.coverPhotoURL == group.coverPhotoURL)
    }
}
