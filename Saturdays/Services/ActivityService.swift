//
//  ActivityService.swift
//  Saturdays
//
//  Tracks and logs user activities for the timeline
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ActivityService {

    static let shared = ActivityService()
    private let db = Firestore.firestore()

    private init() {}

    private var currentUserID: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    // MARK: - Log Activity

    /// Logs an activity event to Firestore
    private func logActivity(
        type: TimelineEventType,
        date: Date = Date(),
        title: String,
        description: String,
        capsuleID: String? = nil,
        capsuleName: String? = nil,
        groupName: String? = nil
    ) {
        guard !currentUserID.isEmpty else {
            print("❌ Cannot log activity: No current user")
            return
        }

        let activityID = UUID().uuidString

        let data: [String: Any] = [
            "id": activityID,
            "userID": currentUserID,
            "type": type.rawValue,
            "date": Timestamp(date: date),
            "title": title,
            "description": description,
            "capsuleID": capsuleID ?? NSNull(),
            "capsuleName": capsuleName ?? NSNull(),
            "groupName": groupName ?? NSNull()
        ]

        db.collection("activities").document(activityID).setData(data) { error in
            if let error = error {
                print("❌ Error logging activity: \(error.localizedDescription)")
            } else {
                print("✅ Activity logged: \(type.rawValue)")
            }
        }
    }

    // MARK: - Capsule Created

    func logCapsuleCreated(capsuleID: String, capsuleName: String, groupName: String) {
        logActivity(
            type: .capsuleCreated,
            title: "Capsule Created 📦",
            description: "Created '\(capsuleName)' in \(groupName)",
            capsuleID: capsuleID,
            capsuleName: capsuleName,
            groupName: groupName
        )
    }

    // MARK: - Added to Capsule

    func logAddedToCapsule(capsuleID: String, capsuleName: String, groupName: String, inviterName: String? = nil) {
        let desc = inviterName != nil
            ? "\(inviterName!) added you to '\(capsuleName)'"
            : "You were added to '\(capsuleName)'"

        logActivity(
            type: .addedToCapsule,
            title: "Added to Capsule 🎉",
            description: desc,
            capsuleID: capsuleID,
            capsuleName: capsuleName,
            groupName: groupName
        )
    }

    // MARK: - Photo Added

    func logPhotoAdded(capsuleID: String, capsuleName: String, photoCount: Int) {
        let photoText = photoCount == 1 ? "photo" : "photos"
        logActivity(
            type: .photoAdded,
            title: "Photos Added 📸",
            description: "Added \(photoCount) \(photoText) to '\(capsuleName)'",
            capsuleID: capsuleID,
            capsuleName: capsuleName
        )
    }

    // MARK: - Letter Added

    func logLetterAdded(capsuleID: String, capsuleName: String) {
        logActivity(
            type: .letterAdded,
            title: "Letter Written ✉️",
            description: "Wrote a letter to '\(capsuleName)'",
            capsuleID: capsuleID,
            capsuleName: capsuleName
        )
    }

    // MARK: - Capsule Revealed

    func logCapsuleRevealed(capsuleID: String, capsuleName: String, groupName: String) {
        logActivity(
            type: .capsuleRevealed,
            title: "Capsule Unlocked! 🎁",
            description: "'\(capsuleName)' has been revealed!",
            capsuleID: capsuleID,
            capsuleName: capsuleName,
            groupName: groupName
        )
    }

    // MARK: - Fetch Activities

    /// Fetches all activities for the current user
    func fetchActivities(completion: @escaping ([TimelineEvent]) -> Void) {
        guard !currentUserID.isEmpty else {
            print("❌ Cannot fetch activities: No current user")
            completion([])
            return
        }

        db.collection("activities")
            .whereField("userID", isEqualTo: currentUserID)
            .order(by: "date", descending: false)
            .getDocuments { snapshot, error in

                if let error = error {
                    print("❌ Error fetching activities: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let activities = snapshot?.documents.compactMap { doc -> TimelineEvent? in
                    let data = doc.data()

                    guard let id = data["id"] as? String,
                          let typeRaw = data["type"] as? String,
                          let type = TimelineEventType(rawValue: typeRaw),
                          let dateTimestamp = data["date"] as? Timestamp,
                          let title = data["title"] as? String,
                          let description = data["description"] as? String else {
                        return nil
                    }

                    return TimelineEvent(
                        id: id,
                        type: type,
                        date: dateTimestamp.dateValue(),
                        title: title,
                        description: description,
                        capsuleID: data["capsuleID"] as? String,
                        capsuleName: data["capsuleName"] as? String,
                        groupName: data["groupName"] as? String
                    )
                } ?? []

                print("✅ Fetched \(activities.count) activities")
                completion(activities)
            }
    }
}
