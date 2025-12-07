//
//  CapsuleModelTests.swift
//  SaturdaysTests
//

import Testing
@testable import Saturdays

struct CapsuleModelTests {

    @Test
    func testCapsuleModelInitializationWithDefaults() {
        let capsule = CapsuleModel(type: .memory)

        // Default values
        #expect(capsule.name == "")
        #expect(capsule.type == .memory)
        #expect(capsule.groupID == "")        // ⬅️ your model uses empty string, not nil
        #expect(capsule.mediaURLs.isEmpty)
        #expect(capsule.coverPhotoURL == nil)
        #expect(capsule.finalVideoURL == nil)

        // ID is a UUID string
        #expect(!capsule.id.isEmpty)
    }

    @Test
    func testCapsuleModelInitializationWithCustomValues() {
        let capsule = CapsuleModel(
            name: "Beach Day",
            type: .letter,
            groupID: "group-1",
            coverPhotoURL: nil
        )

        #expect(capsule.name == "Beach Day")
        #expect(capsule.type == .letter)
        #expect(capsule.groupID == "group-1")
    }

    @Test
    func testCapsuleModelIDsAreUnique() {
        let c1 = CapsuleModel(type: .memory)
        let c2 = CapsuleModel(type: .memory)

        #expect(c1.id != c2.id)
    }

    @Test
    func testCapsuleTypeEnumValues() {
        #expect(CapsuleType.memory != CapsuleType.letter)
    }
}
