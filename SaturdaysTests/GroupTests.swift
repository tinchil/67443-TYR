//
//  GroupTests.swift
//  SaturdaysTests
//
//  Created by Yining He  on 11/10/25.
//

import Testing
@testable import Saturdays

struct GroupTests {
    
    // MARK: - Helper Data
    let sampleFriends = [
        Friend(name: "Ria He", username: "@riahe"),
        Friend(name: "Alex Chen", username: "@alexchen")
    ]
    
    // MARK: - Capsule Tests
    
    @Test func testCapsuleInitialization() throws {
        let now = Date()
        let revealDate = Calendar.current.date(byAdding: .day, value: 7, to: now)!
        let lockDate = Calendar.current.date(byAdding: .day, value: 3, to: now)!
        
        let capsule = Capsule(
            name: "Weekend Trip",
            description: "Photos from our Boston weekend",
            type: .travel,
            revealDate: revealDate,
            revealCycle: .oneTime,
            lockPeriod: lockDate,
            contributionRequirement: .minimum,
            photos: []
        )
        
        #expect(capsule.name == "Weekend Trip")
        #expect(capsule.type == .travel)
        #expect(capsule.revealCycle == .oneTime)
        #expect(capsule.contributionRequirement == .minimum)
        #expect(capsule.photos.isEmpty)
        #expect(capsule.revealDate > now)
        #expect(capsule.lockPeriod < capsule.revealDate)
    }
    
    // MARK: - Enum Tests
    
    @Test func testCapsuleTypeRawValues() throws {
        #expect(CapsuleType.memories.rawValue == "Memories")
        #expect(CapsuleType.friendship.rawValue == "Friendship")
        #expect(CapsuleType.allCases.count == 5)
    }
    
    @Test func testRevealCycleAllCases() throws {
        #expect(RevealCycle.allCases.contains(.weekly))
        #expect(RevealCycle.allCases.count == 5)
    }
    
    @Test func testContributionRequirementCases() throws {
        #expect(ContributionRequirement.maximum.rawValue == "Maximum")
        #expect(ContributionRequirement.allCases.count == 5)
    }
    
    // MARK: - Group Tests
    
    @Test func testGroupInitializationWithoutCapsule() throws {
        let group = Group(name: "CMU Crew", members: sampleFriends, capsule: nil)
        
        #expect(group.name == "CMU Crew")
        #expect(group.members.count == 2)
        #expect(group.capsule == nil)
    }
    
    @Test func testGroupInitializationWithCapsule() throws {
        let capsule = Capsule(
            name: "Spring Memories",
            description: "A collection of photos from the semester",
            type: .memories,
            revealDate: Date(),
            revealCycle: .monthly,
            lockPeriod: Date(),
            contributionRequirement: .none,
            photos: []
        )
        
        let group = Group(name: "Saturdays Squad", members: sampleFriends, capsule: capsule)
        
        #expect(group.capsule != nil)
        #expect(group.capsule?.type == .memories)
        #expect(group.members.first?.name == "Ria He")
        #expect(group.id != group.capsule?.id) // IDs are unique per struct
    }
}
