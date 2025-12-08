//
//  TimelineService.swift
//  Saturdays
//
//  Created by Claude on 12/7/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class TimelineService {

    private let db = Firestore.firestore()

    private var currentUserID: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    // MARK: - Fetch User Timeline
    func fetchUserTimeline(completion: @escaping ([TimelineEvent]) -> Void) {
        guard !currentUserID.isEmpty else {
            print("❌ No current user ID")
            completion([])
            return
        }

        var events: [TimelineEvent] = []
        let group = DispatchGroup()

        // 1. Account Created
        group.enter()
        fetchAccountCreatedEvent { event in
            if let event = event {
                events.append(event)
            }
            group.leave()
        }

        // 2. First Friend
        group.enter()
        fetchFirstFriendEvent { event in
            if let event = event {
                events.append(event)
            }
            group.leave()
        }

        // 3. First Group
        group.enter()
        fetchFirstGroupEvent { event in
            if let event = event {
                events.append(event)
            }
            group.leave()
        }

        // 4. First Capsule
        group.enter()
        fetchFirstCapsuleEvent { event in
            if let event = event {
                events.append(event)
            }
            group.leave()
        }

        // 5. First Photo
        group.enter()
        fetchFirstPhotoEvent { event in
            if let event = event {
                events.append(event)
            }
            group.leave()
        }

        group.notify(queue: .main) {
            // Sort by date (oldest first)
            let sortedEvents = events.sorted { $0.date < $1.date }
            print("📅 Fetched \(sortedEvents.count) timeline events")
            completion(sortedEvents)
        }
    }

    // MARK: - Individual Event Fetchers

    private func fetchAccountCreatedEvent(completion: @escaping (TimelineEvent?) -> Void) {
        db.collection("users").document(currentUserID).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching account creation: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = snapshot?.data(),
                  let createdAt = data["createdAt"] as? Timestamp else {
                completion(nil)
                return
            }

            let event = TimelineEvent(
                type: .accountCreated,
                date: createdAt.dateValue(),
                title: "Welcome to Saturdays! 🎉",
                description: "Your journey begins here"
            )
            print("✅ Account created: \(createdAt.dateValue())")
            completion(event)
        }
    }

    private func fetchFirstFriendEvent(completion: @escaping (TimelineEvent?) -> Void) {
        db.collection("users").document(currentUserID).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching first friend: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = snapshot?.data(),
                  let friendIDs = data["friendIDs"] as? [String],
                  !friendIDs.isEmpty else {
                print("ℹ️ No friends found")
                completion(nil)
                return
            }

            // We don't have exact timestamp of when friend was added, so use account creation + 1 day
            // In a real app, you'd store friend relationship timestamps
            if let createdAt = data["createdAt"] as? Timestamp {
                let event = TimelineEvent(
                    type: .firstFriend,
                    date: createdAt.dateValue().addingTimeInterval(86400), // +1 day
                    title: "First Friend Added! 👥",
                    description: "You've made your first connection"
                )
                print("✅ First friend milestone")
                completion(event)
            } else {
                completion(nil)
            }
        }
    }

    private func fetchFirstGroupEvent(completion: @escaping (TimelineEvent?) -> Void) {
        db.collection("groups")
            .whereField("memberIDs", arrayContains: currentUserID)
            .order(by: "createdAt", descending: false)
            .limit(to: 1)
            .getDocuments { snapshot, error in

                if let error = error {
                    print("❌ Error fetching first group: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let doc = snapshot?.documents.first,
                      let data = doc.data() as? [String: Any],
                      let createdAt = data["createdAt"] as? Timestamp,
                      let groupName = data["name"] as? String else {
                    print("ℹ️ No groups found")
                    completion(nil)
                    return
                }

                let event = TimelineEvent(
                    type: .firstGroup,
                    date: createdAt.dateValue(),
                    title: "First Group Created! 🎊",
                    description: "Started '\(groupName)' with your friends"
                )
                print("✅ First group: \(groupName)")
                completion(event)
            }
    }

    private func fetchFirstCapsuleEvent(completion: @escaping (TimelineEvent?) -> Void) {
        // Get user's groups first
        db.collection("users").document(currentUserID).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let groupIDs = data["groupIDs"] as? [String],
                  !groupIDs.isEmpty else {
                print("ℹ️ No groups to check for capsules")
                completion(nil)
                return
            }

            // Find first capsule in any of user's groups
            self.db.collection("capsules")
                .whereField("groupID", in: groupIDs)
                .order(by: "createdAt", descending: false)
                .limit(to: 1)
                .getDocuments { snapshot, error in

                    if let error = error {
                        print("❌ Error fetching first capsule: \(error.localizedDescription)")
                        completion(nil)
                        return
                    }

                    guard let doc = snapshot?.documents.first,
                          let data = doc.data() as? [String: Any],
                          let createdAt = data["createdAt"] as? Timestamp,
                          let capsuleName = data["name"] as? String else {
                        print("ℹ️ No capsules found")
                        completion(nil)
                        return
                    }

                    let event = TimelineEvent(
                        type: .firstCapsule,
                        date: createdAt.dateValue(),
                        title: "First Capsule Created! 📦",
                        description: "Created '\(capsuleName)' - your first memory capsule"
                    )
                    print("✅ First capsule: \(capsuleName)")
                    completion(event)
                }
        }
    }

    private func fetchFirstPhotoEvent(completion: @escaping (TimelineEvent?) -> Void) {
        // Get user's groups first
        db.collection("users").document(currentUserID).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let groupIDs = data["groupIDs"] as? [String],
                  !groupIDs.isEmpty else {
                print("ℹ️ No groups to check for photos")
                completion(nil)
                return
            }

            // Find first capsule with photos
            self.db.collection("capsules")
                .whereField("groupID", in: groupIDs)
                .whereField("createdBy", isEqualTo: self.currentUserID)
                .order(by: "createdAt", descending: false)
                .getDocuments { snapshot, error in

                    if let error = error {
                        print("❌ Error fetching first photo: \(error.localizedDescription)")
                        completion(nil)
                        return
                    }

                    // Find first capsule that has photos
                    for doc in snapshot?.documents ?? [] {
                        if let data = doc.data() as? [String: Any],
                           let mediaURLs = data["mediaURLs"] as? [String],
                           !mediaURLs.isEmpty,
                           let createdAt = data["createdAt"] as? Timestamp {

                            let event = TimelineEvent(
                                type: .firstPhoto,
                                date: createdAt.dateValue(),
                                title: "First Photo Uploaded! 📸",
                                description: "You added your first memory to a capsule"
                            )
                            print("✅ First photo milestone")
                            completion(event)
                            return
                        }
                    }

                    print("ℹ️ No photos found")
                    completion(nil)
                }
        }
    }
}
