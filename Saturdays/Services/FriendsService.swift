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

    // MARK: - SEND REQUEST
    func sendFriendRequest(
        to user: UserModel,
        from: UserModel,
        completion: @escaping (Bool) -> Void
    ) {
        let requestID = "\(currentUserID)_to_\(user.id)"

        let ref = db.collection("users")
            .document(user.id)
            .collection("friendRequests")
            .document(requestID)

        ref.setData([
            "id": requestID,
            "fromUserID": currentUserID,
            "fromUsername": from.username,
            "fromDisplayName": from.displayName,
            "toUserID": user.id,
            "createdAt": Date()
        ]) { error in
            completion(error == nil)
        }
    }

    // MARK: - ACCEPT REQUEST
    func acceptRequest(
        _ request: FriendRequest,
        currentUser: UserModel,
        completion: @escaping (Bool) -> Void
    ) {

        let batch = db.batch()

        // Add friend to ME
        let myRef = db.collection("users")
            .document(currentUserID)
            .collection("friends")
            .document(request.fromUserID)

        batch.setData([
            "id": request.fromUserID,
            "userID": request.fromUserID,
            "username": request.fromUsername,
            "displayName": request.fromDisplayName,
            "createdAt": Date()
        ], forDocument: myRef)

        // Add ME to their list
        let theirRef = db.collection("users")
            .document(request.fromUserID)
            .collection("friends")
            .document(currentUser.id)

        batch.setData([
            "id": currentUser.id,
            "userID": currentUser.id,
            "username": currentUser.username,
            "displayName": currentUser.displayName,
            "createdAt": Date()
        ], forDocument: theirRef)

        // Delete request
        let reqRef = db.collection("users")
            .document(currentUserID)
            .collection("friendRequests")
            .document(request.id)

        batch.deleteDocument(reqRef)

        batch.commit { error in
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

        let myRef = db.collection("users")
            .document(currentUserID)
            .collection("friends")
            .document(friend.userID)

        let theirRef = db.collection("users")
            .document(friend.userID)
            .collection("friends")
            .document(currentUserID)

        batch.deleteDocument(myRef)
        batch.deleteDocument(theirRef)

        batch.commit { error in
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
            .collection("friends")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, _ in

                let friends = snapshot?.documents.compactMap {
                    try? $0.data(as: Friend.self)
                } ?? []

                completion(friends)
            }
    }
}
