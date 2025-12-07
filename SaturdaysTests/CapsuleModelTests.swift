//
//  CapsuleModelTests.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/5/25.
//


//  CapsuleModelTests.swift
//  SaturdaysTests

import Testing
import UIKit
@testable import Saturdays

struct CapsuleModelTests {

    @Test
    func testCapsuleModelInitializationWithDefaults() {
        let capsule = CapsuleModel(type: .memory)

        #expect(capsule.name == "")
        #expect(capsule.type == .memory)
        #expect(capsule.groupID == nil)

        // Only check that an ID exists – not its value
        #expect(!capsule.id.uuidString.isEmpty)
    }

    @Test
    func testCapsuleModelInitializationWithCustomValues() {
        let capsule = CapsuleModel(
            name: "Beach Day",
            type: .letter,
            groupID: "group-1",
            coverPhoto: nil
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
        let memory = CapsuleType.memory
        let letter = CapsuleType.letter

        #expect(memory != letter)
    }
}
