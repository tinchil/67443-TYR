// FriendTests.swift
import Testing
import Foundation
@testable import Saturdays

struct FriendTests {

    @Test
    func testFriendInitializationStoresAllFields() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        let friend = Friend(
            id: "friend-123",
            userID: "user-123",
            username: "@riahe",
            displayName: "Ria He",
            createdAt: now
        )

        #expect(friend.id == "friend-123")
        #expect(friend.userID == "user-123")
        #expect(friend.username == "@riahe")
        #expect(friend.displayName == "Ria He")
        #expect(friend.createdAt == now)
    }

    @Test
    func testFriendIdentifiableUsesID() {
        let friend = Friend(
            id: "abc",
            userID: "abc",
            username: "@abc",
            displayName: "ABC",
            createdAt: Date(timeIntervalSince1970: 1_700_000_100)
        )

        #expect(friend.id == "abc")
    }

    @Test
    func testFriendCodableRoundTrip() throws {
        // Use a fixed timestamp without fractional seconds
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        let friend = Friend(
            id: "friend-999",
            userID: "user-999",
            username: "@testuser",
            displayName: "Test User",
            createdAt: now
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(friend)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Friend.self, from: data)

        #expect(decoded.id == friend.id)
        #expect(decoded.userID == friend.userID)
        #expect(decoded.username == friend.username)
        #expect(decoded.displayName == friend.displayName)
        #expect(decoded.createdAt == friend.createdAt)
    }
}
