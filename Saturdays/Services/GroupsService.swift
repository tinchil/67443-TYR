//
//  GroupsService.swift
//  Saturdays
//
//  Created by Tin on 12/5/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class GroupsService {

    private let db = Firestore.firestore()

    private var currentUserID: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    // MARK: - CREATE GROUP
    func createGroup(
        name: String,
        memberIDs: [String],
        completion: @escaping (String?) -> Void
    ) {
        let groupID = UUID().uuidString
        let batch = db.batch()

        // Create the group document in groups collection
        let groupRef = db.collection("groups").document(groupID)
        batch.setData([
            "id": groupID,
            "name": name,
            "memberIDs": memberIDs,
            "createdBy": currentUserID,
            "createdAt": Date()
        ], forDocument: groupRef)

        // Add groupID to each member's groupIDs array (including creator)
        for memberID in memberIDs {
            let userRef = db.collection("users").document(memberID)
            batch.setData([
                "groupIDs": FieldValue.arrayUnion([groupID])
            ], forDocument: userRef, merge: true)
        }

        batch.commit { error in
            if let error = error {
                print("❌ Error creating group: \(error.localizedDescription)")
                completion(nil)
            } else {
                print("✅ Group '\(name)' created successfully with ID: \(groupID)")
                print("📋 Members: \(memberIDs)")
                completion(groupID)
            }
        }
    }

    // MARK: - FETCH GROUPS (One-time fetch)
    func fetchUserGroups(completion: @escaping ([GroupModel]) -> Void) {
        guard !currentUserID.isEmpty else {
            print("❌ No current user ID")
            completion([])
            return
        }

        // Fetch user's groupIDs array
        db.collection("users").document(currentUserID).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching user's groups: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let data = snapshot?.data(),
                  let groupIDs = data["groupIDs"] as? [String] else {
                print("ℹ️ No groupIDs found or empty")
                completion([])
                return
            }

            if groupIDs.isEmpty {
                completion([])
                return
            }

            print("📋 Found \(groupIDs.count) group IDs: \(groupIDs)")

            // Fetch details for each group
            let group = DispatchGroup()
            var fetchedGroups: [GroupModel] = []

            for groupID in groupIDs {
                group.enter()
                self.db.collection("groups").document(groupID).getDocument { doc, _ in
                    defer { group.leave() }

                    if let doc = doc,
                       let groupData = try? doc.data(as: GroupModel.self) {
                        fetchedGroups.append(groupData)
                        print("✅ Fetched group: \(groupData.name)")
                    }
                }
            }

            group.notify(queue: .main) {
                print("📤 Returning \(fetchedGroups.count) groups to UI")
                completion(fetchedGroups.sorted { $0.createdAt < $1.createdAt })
            }
        }
    }

    // MARK: - DELETE GROUP
    func deleteGroup(_ group: GroupModel, completion: @escaping (Bool) -> Void) {
        let batch = db.batch()

        // Delete the group document
        let groupRef = db.collection("groups").document(group.id)
        batch.deleteDocument(groupRef)

        // Remove groupID from all members' groupIDs arrays
        for memberID in group.memberIDs {
            let userRef = db.collection("users").document(memberID)
            batch.setData([
                "groupIDs": FieldValue.arrayRemove([group.id])
            ], forDocument: userRef, merge: true)
        }

        batch.commit { error in
            if let error = error {
                print("❌ Error deleting group: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Group '\(group.name)' deleted successfully")
                completion(true)
            }
        }
    }

    // MARK: - REALTIME LISTENER
    func listenForGroups(completion: @escaping ([GroupModel]) -> Void)
        -> ListenerRegistration? {

        guard !currentUserID.isEmpty else {
            print("❌ No current user ID")
            completion([])
            return nil
        }

        return db.collection("users")
            .document(currentUserID)
            .addSnapshotListener { [weak self] snapshot, error in

                if let error = error {
                    print("❌ Error listening for groups: \(error.localizedDescription)")
                    completion([])
                    return
                }

                guard let self = self,
                      let data = snapshot?.data(),
                      let groupIDs = data["groupIDs"] as? [String] else {
                    print("ℹ️ No groupIDs found or empty")
                    completion([])
                    return
                }

                if groupIDs.isEmpty {
                    completion([])
                    return
                }

                print("📋 Found \(groupIDs.count) group IDs: \(groupIDs)")

                // Fetch details for each group
                let group = DispatchGroup()
                var fetchedGroups: [GroupModel] = []

                for groupID in groupIDs {
                    group.enter()
                    self.db.collection("groups").document(groupID).getDocument { doc, _ in
                        defer { group.leave() }

                        if let doc = doc,
                           let groupData = try? doc.data(as: GroupModel.self) {
                            fetchedGroups.append(groupData)
                            print("✅ Fetched group: \(groupData.name)")
                        }
                    }
                }

                group.notify(queue: .main) {
                    print("📤 Returning \(fetchedGroups.count) groups to UI")
                    completion(fetchedGroups.sorted { $0.createdAt < $1.createdAt })
                }
            }
    }
}
