//
//  Friend.swift
//  Saturdays
//
//  Created by Claude Code
//

import Foundation

struct Friend: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let username: String
    let avatarImage: String? = nil // For future implementation

    // Sample data for testing
    static let sampleFriends: [Friend] = [
        Friend(name: "Jenny Kim", username: "@jennykim"),
        Friend(name: "Alex Chen", username: "@alexchen"),
        Friend(name: "Maria Garcia", username: "@mariagarcia"),
        Friend(name: "Sofia Martinez", username: "@sofiamartinez"),
        Friend(name: "Taylor Swift", username: "@taylorswift"),
        Friend(name: "Jordan Lee", username: "@jordanlee"),
        Friend(name: "Sam Wilson", username: "@samwilson"),
        Friend(name: "Chris Evans", username: "@chrisevans"),
        Friend(name: "Morgan Freeman", username: "@morganfreeman")
    ]
}
