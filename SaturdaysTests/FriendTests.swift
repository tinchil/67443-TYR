//
//  FriendTests.swift
//  SaturdaysTests
//
//  Created by Yining He  on 11/10/25.
//

import Testing
@testable import Saturdays

struct FriendTests {
    
    @Test func testFriendInitialization() throws {
        let friend = Friend(name: "Ria He", username: "@riahe")
        
        #expect(friend.name == "Ria He")
        #expect(friend.username == "@riahe")
        #expect(friend.avatarImage == nil)
    }
    
    @Test func testUniqueIDs() throws {
        let friend1 = Friend(name: "Alex", username: "@alex")
        let friend2 = Friend(name: "Maria", username: "@maria")
        
        #expect(friend1.id != friend2.id)
    }
    
    @Test func testSampleFriendsCount() throws {
        #expect(Friend.sampleFriends.count == 9)
    }
    
    @Test func testSampleIncludesTaylor() throws {
        let names = Friend.sampleFriends.map { $0.name }
        #expect(names.contains("Taylor Swift"))
    }
    
    @Test func testHashableConformance() throws {
        let friend = Friend(name: "Jordan Lee", username: "@jordanlee")
        let set: Set<Friend> = [friend]
        #expect(set.contains(friend))
    }
}
