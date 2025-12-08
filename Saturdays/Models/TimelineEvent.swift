//
//  TimelineEvent.swift
//  Saturdays
//
//  Created by Claude on 12/7/25.
//

import Foundation

enum TimelineEventType: String, Codable {
    case accountCreated = "account_created"
    case firstFriend = "first_friend"
    case firstGroup = "first_group"
    case firstCapsule = "first_capsule"
    case firstPhoto = "first_photo"

    var icon: String {
        switch self {
        case .accountCreated: return "person.fill.checkmark"
        case .firstFriend: return "person.2.fill"
        case .firstGroup: return "person.3.fill"
        case .firstCapsule: return "cube.fill"
        case .firstPhoto: return "photo.fill"
        }
    }

    var color: String {
        switch self {
        case .accountCreated: return "blue"
        case .firstFriend: return "green"
        case .firstGroup: return "purple"
        case .firstCapsule: return "orange"
        case .firstPhoto: return "pink"
        }
    }
}

struct TimelineEvent: Identifiable, Codable {
    let id: String
    let type: TimelineEventType
    let date: Date
    let title: String
    let description: String

    init(id: String = UUID().uuidString, type: TimelineEventType, date: Date, title: String, description: String) {
        self.id = id
        self.type = type
        self.date = date
        self.title = title
        self.description = description
    }
}
