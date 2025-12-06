// UserModelTests.swift
import Testing
import Foundation
@testable import Saturdays

struct UserModelTests {

    @Test
    func testUserModelInitializationDefaultsRelationshipArrays() {
        let user = UserModel(
            id: "user-1",
            username: "@rosemary",
            displayName: "Rosemary Yang",
            email: "ryang@example.com",
            createdAt: Date(timeIntervalSince1970: 1_700_000_000)
        )

        #expect(user.friendIDs.isEmpty)
        #expect(user.incomingRequests.isEmpty)
        #expect(user.outgoingRequests.isEmpty)
        #expect(user.groupIDs.isEmpty)
    }

    @Test
    func testUserModelCanStoreRelationships() {
        var user = UserModel(
            id: "user-2",
            username: "@test",
            displayName: "Test User",
            email: "test@example.com",
            createdAt: Date(timeIntervalSince1970: 1_700_000_100)
        )

        user.friendIDs = ["f1", "f2"]
        user.incomingRequests = ["req-in-1"]
        user.outgoingRequests = ["req-out-1", "req-out-2"]
        user.groupIDs = ["g1"]

        #expect(user.friendIDs.count == 2)
        #expect(user.incomingRequests.count == 1)
        #expect(user.outgoingRequests.count == 2)
        #expect(user.groupIDs.count == 1)
    }

    @Test
    func testUserModelCodableRoundTrip() throws {
        let user = UserModel(
            id: "user-3",
            username: "@encoded",
            displayName: "Encoded User",
            email: "encoded@example.com",
            createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            friendIDs: ["f1"],
            incomingRequests: ["req1"],
            outgoingRequests: ["req2"],
            groupIDs: ["g1", "g2"]
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(user)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(UserModel.self, from: data)

        #expect(decoded.id == user.id)
        #expect(decoded.username == user.username)
        #expect(decoded.displayName == user.displayName)
        #expect(decoded.email == user.email)
        #expect(decoded.createdAt == user.createdAt)
        #expect(decoded.friendIDs == user.friendIDs)
        #expect(decoded.incomingRequests == user.incomingRequests)
        #expect(decoded.outgoingRequests == user.outgoingRequests)
        #expect(decoded.groupIDs == user.groupIDs)
    }
}
