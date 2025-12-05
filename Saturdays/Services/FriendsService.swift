//
//  FriendsService.swift
//  Saturdays
//
//  Created by Yining He  on 12/3/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FriendsService {

    private let db = Firestore.firestore()

    private var currentUserID: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    // MARK: - SEARCH USER
    func searchUser(username: String, completion: @escaping (UserModel?) -> Void) {
        db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments { snapshot, _ in

                guard let doc = snapshot?.documents.first else {
                    completion(nil)
                    return
                }

                completion(try? doc.data(as: UserModel.self))
            }
    }

    // MARK: - SEND REQUEST (OLD - WITH APPROVAL)
    // func sendFriendRequest(
    //     to user: UserModel,
    //     from: UserModel,
    //     completion: @escaping (Bool) -> Void
    // ) {
    //     let requestID = "\(currentUserID)_to_\(user.id)"
    //
    //     let ref = db.collection("users")
    //         .document(user.id)
    //         .collection("friendRequests")
    //         .document(requestID)
    //
    //     ref.setData([
    //         "id": requestID,
    //         "fromUserID": currentUserID,
    //         "fromUsername": from.username,
    //         "fromDisplayName": from.displayName,
    //         "toUserID": user.id,
    //         "createdAt": Date()
    //     ]) { error in
    //         completion(error == nil)
    //     }
    // }

    // MARK: - ADD FRIEND (NEW - INSTANT)
    func sendFriendRequest(
        to user: UserModel,
        from: UserModel,
        completion: @escaping (Bool) -> Void
    ) {
        let batch = db.batch()

        // Add their UID to MY friendIDs array
        let myRef = db.collection("users").document(currentUserID)
        batch.setData([
            "friendIDs": FieldValue.arrayUnion([user.id])
        ], forDocument: myRef, merge: true)

        // Add MY UID to their friendIDs array
        let theirRef = db.collection("users").document(user.id)
        batch.setData([
            "friendIDs": FieldValue.arrayUnion([currentUserID])
        ], forDocument: theirRef, merge: true)

        batch.commit { error in
            if let error = error {
                print("❌ Error adding friend: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Friend added successfully")
                completion(true)
            }
        }
    }

    // MARK: - ACCEPT REQUEST
    func acceptRequest(
        _ request: FriendRequest,
        currentUser: UserModel,
        completion: @escaping (Bool) -> Void
    ) {

        let batch = db.batch()

        // Add their UID to MY friendIDs array
        let myRef = db.collection("users").document(currentUserID)
        batch.setData([
            "friendIDs": FieldValue.arrayUnion([request.fromUserID])
        ], forDocument: myRef, merge: true)

        // Add MY UID to their friendIDs array
        let theirRef = db.collection("users").document(request.fromUserID)
        batch.setData([
            "friendIDs": FieldValue.arrayUnion([currentUser.id])
        ], forDocument: theirRef, merge: true)

        // Delete request
        let reqRef = db.collection("users")
            .document(currentUserID)
            .collection("friendRequests")
            .document(request.id)

        batch.deleteDocument(reqRef)

        batch.commit { error in
            if let error = error {
                print("❌ Error accepting request: \(error.localizedDescription)")
            }
            completion(error == nil)
        }
    }

    // MARK: - DELETE REQUEST
    func deleteRequest(_ request: FriendRequest, completion: @escaping (Bool) -> Void) {
        db.collection("users")
            .document(currentUserID)
            .collection("friendRequests")
            .document(request.id)
            .delete { error in
                completion(error == nil)
            }
    }

    // MARK: - REMOVE FRIEND
    func removeFriend(_ friend: Friend, completion: @escaping (Bool) -> Void) {

        let batch = db.batch()

        // Remove their UID from MY friendIDs array
        let myRef = db.collection("users").document(currentUserID)
        batch.setData([
            "friendIDs": FieldValue.arrayRemove([friend.userID])
        ], forDocument: myRef, merge: true)

        // Remove MY UID from their friendIDs array
        let theirRef = db.collection("users").document(friend.userID)
        batch.setData([
            "friendIDs": FieldValue.arrayRemove([currentUserID])
        ], forDocument: theirRef, merge: true)

        batch.commit { error in
            if let error = error {
                print("❌ Error removing friend: \(error.localizedDescription)")
            }
            completion(error == nil)
        }
    }

    // MARK: - REALTIME LISTENERS
    func listenForIncomingRequests(completion: @escaping ([FriendRequest]) -> Void)
        -> ListenerRegistration {

        return db.collection("users")
            .document(currentUserID)
            .collection("friendRequests")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, _ in

                let requests = snapshot?.documents.compactMap {
                    try? $0.data(as: FriendRequest.self)
                } ?? []

                completion(requests)
            }
    }

    func listenForFriendsList(completion: @escaping ([Friend]) -> Void)
        -> ListenerRegistration {

        return db.collection("users")
            .document(currentUserID)
            .addSnapshotListener { [weak self] snapshot, error in

                if let error = error {
                    print("❌ Error listening for friends: \(error.localizedDescription)")
                    completion([])
                    return
                }

                guard let self = self,
                      let data = snapshot?.data(),
                      let friendIDs = data["friendIDs"] as? [String] else {
                    print("ℹ️ No friendIDs found or empty")
                    completion([])
                    return
                }

                print("📋 Found \(friendIDs.count) friend IDs: \(friendIDs)")

                // If no friends, return empty array
                if friendIDs.isEmpty {
                    completion([])
                    return
                }

                // Fetch details for each friend UID
                let group = DispatchGroup()
                var fetchedFriends: [Friend] = []

                for friendID in friendIDs {
                    group.enter()
                    self.db.collection("users").document(friendID).getDocument { doc, _ in
                        defer { group.leave() }

                        if let doc = doc,
                           let userData = try? doc.data(as: UserModel.self) {
                            let friend = Friend(
                                id: userData.id,
                                userID: userData.id,
                                username: userData.username,
                                displayName: userData.displayName,
                                createdAt: userData.createdAt
                            )
                            fetchedFriends.append(friend)
                            print("✅ Fetched friend: \(userData.username)")
                        }
                    }
                }

                group.notify(queue: .main) {
                    // Sort by username for consistent ordering
                    print("📤 Returning \(fetchedFriends.count) friends to UI")
                    completion(fetchedFriends.sorted { $0.username < $1.username })
                }
            }
    }
}
