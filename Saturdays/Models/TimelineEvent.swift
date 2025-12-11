//
//  TimelineEvent.swift
//  Saturdays
//
//  Created by Claude on 12/7/25.
//

import Foundation

enum TimelineEventType: String, Codable {
    // Milestones (first-time events)
    case accountCreated = "account_created"
    case firstFriend = "first_friend"
    case firstGroup = "first_group"
    case firstCapsule = "first_capsule"
    case firstPhoto = "first_photo"

    // Capsule Activities (recurring events)
    case capsuleCreated = "capsule_created"
    case addedToCapsule = "added_to_capsule"
    case photoAdded = "photo_added"
    case letterAdded = "letter_added"
    case capsuleRevealed = "capsule_revealed"

    var icon: String {
        switch self {
        case .accountCreated: return "person.fill.checkmark"
        case .firstFriend: return "person.2.fill"
        case .firstGroup: return "person.3.fill"
        case .firstCapsule: return "cube.fill"
        case .firstPhoto: return "photo.fill"
        case .capsuleCreated: return "sparkles.square.filled.on.square"
        case .addedToCapsule: return "person.badge.plus"
        case .photoAdded: return "photo.badge.plus"
        case .letterAdded: return "envelope.badge.fill"
        case .capsuleRevealed: return "gift.fill"
        }
    }

    var color: String {
        switch self {
        case .accountCreated: return "blue"
        case .firstFriend: return "green"
        case .firstGroup: return "purple"
        case .firstCapsule: return "orange"
        case .firstPhoto: return "pink"
        case .capsuleCreated: return "orange"
        case .addedToCapsule: return "blue"
        case .photoAdded: return "pink"
        case .letterAdded: return "indigo"
        case .capsuleRevealed: return "yellow"
        }
    }
}

struct TimelineEvent: Identifiable, Codable {
    let id: String
    let type: TimelineEventType
    let date: Date
    let title: String
    let description: String

    // Optional metadata for capsule events
    let capsuleID: String?
    let capsuleName: String?
    let groupName: String?

    init(
        id: String = UUID().uuidString,
        type: TimelineEventType,
        date: Date,
        title: String,
        description: String,
        capsuleID: String? = nil,
        capsuleName: String? = nil,
        groupName: String? = nil
    ) {
        self.id = id
        self.type = type
        self.date = date
        self.title = title
        self.description = description
        self.capsuleID = capsuleID
        self.capsuleName = capsuleName
        self.groupName = groupName
    }
}
