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

    // MOCK DATA - Remove this when connecting to Firebase
    private var mockGroups: [GroupModel] = [
        GroupModel(
            id: "group1",
            name: "Herstorians",
            memberIDs: ["user1", "user2", "user3"],
            createdBy: "user1",
            createdAt: Date()
        ),
        GroupModel(
            id: "group2",
            name: "Coffee Chats",
            memberIDs: ["user1", "user4", "user5"],
            createdBy: "user1",
            createdAt: Date()
        ),
        GroupModel(
            id: "group3",
            name: "Dog Eaters",
            memberIDs: ["user1", "user6", "user7", "user8"],
            createdBy: "user1",
            createdAt: Date()
        )
    ]

    // FIREBASE SETUP (commented for now)
    // private let db = Firestore.firestore()
    //
    // private var currentUserID: String {
    //     Auth.auth().currentUser?.uid ?? ""
    // }

    // MARK: - CREATE GROUP
    func createGroup(
        name: String,
        memberIDs: [String],
        completion: @escaping (String?) -> Void
    ) {
        // MOCK VERSION - Using local data
        let groupID = UUID().uuidString
        let newGroup = GroupModel(
            id: groupID,
            name: name,
            memberIDs: memberIDs,
            createdBy: "currentUser", // Mock current user
            createdAt: Date()
        )
        mockGroups.append(newGroup)
        completion(groupID)

        /* FIREBASE VERSION - Uncomment when ready to connect
        let groupID = UUID().uuidString
        let batch = db.batch()

        // Add group to each member's groups collection
        for memberID in memberIDs {
            let groupRef = db.collection("users")
                .document(memberID)
                .collection("groups")
                .document(groupID)

            batch.setData([
                "id": groupID,
                "name": name,
                "memberIDs": memberIDs,
                "createdBy": currentUserID,
                "createdAt": Date()
            ], forDocument: groupRef)
        }

        batch.commit { error in
            if error == nil {
                completion(groupID)
            } else {
                completion(nil)
            }
        }
        */
    }

    // MARK: - FETCH GROUPS (One-time fetch)
    func fetchUserGroups(completion: @escaping ([GroupModel]) -> Void) {
        // MOCK VERSION - Return local data
        completion(mockGroups)

        /* FIREBASE VERSION - Uncomment when ready to connect
        guard !currentUserID.isEmpty else {
            completion([])
            return
        }

        db.collection("users")
            .document(currentUserID)
            .collection("groups")
            .order(by: "createdAt", descending: false)
            .getDocuments { snapshot, _ in

                let groups = snapshot?.documents.compactMap {
                    try? $0.data(as: GroupModel.self)
                } ?? []

                completion(groups)
            }
        */
    }

    // MARK: - DELETE GROUP
    func deleteGroup(_ group: GroupModel, completion: @escaping (Bool) -> Void) {
        // MOCK VERSION - Remove from local array
        mockGroups.removeAll { $0.id == group.id }
        completion(true)

        /* FIREBASE VERSION - Uncomment when ready to connect
        let batch = db.batch()

        // Remove group from all members' collections
        for memberID in group.memberIDs {
            let groupRef = db.collection("users")
                .document(memberID)
                .collection("groups")
                .document(group.id)

            batch.deleteDocument(groupRef)
        }

        batch.commit { error in
            completion(error == nil)
        }
        */
    }

    // MARK: - REALTIME LISTENER
    func listenForGroups(completion: @escaping ([GroupModel]) -> Void)
        -> ListenerRegistration? {

        // MOCK VERSION - Just return groups immediately (no real listener)
        completion(mockGroups)
        return nil  // No listener to return in mock mode

        /* FIREBASE VERSION - Uncomment when ready to connect
        return db.collection("users")
            .document(currentUserID)
            .collection("groups")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, _ in

                let groups = snapshot?.documents.compactMap {
                    try? $0.data(as: GroupModel.self)
                } ?? []

                completion(groups)
            }
        */
    }
}
