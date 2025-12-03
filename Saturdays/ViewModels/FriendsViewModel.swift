//
//  FriendsViewModel.swift
//  Saturdays
//
//  Created by Yining He  on 12/3/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class FriendsViewModel: ObservableObject {

    @Published var searchText = ""
    @Published var searchResult: UserModel?

    @Published var requests: [FriendRequest] = []
    @Published var friends: [Friend] = []

    private let service = FriendsService()

    private var requestsListener: ListenerRegistration?
    private var friendsListener: ListenerRegistration?

    init() {
        attachListeners()
    }

    deinit {
        removeListeners()
    }

    // MARK: - LISTENERS
    func attachListeners() {
        removeListeners()

        requestsListener = service.listenForIncomingRequests { [weak self] requests in
            DispatchQueue.main.async {
                self?.requests = requests
            }
        }

        friendsListener = service.listenForFriendsList { [weak self] friends in
            DispatchQueue.main.async {
                self?.friends = friends
            }
        }
    }

    func removeListeners() {
        requestsListener?.remove()
        friendsListener?.remove()
        requestsListener = nil
        friendsListener = nil
    }

    // MARK: - SEARCH
    func search() {
        guard searchText.count > 1 else {
            searchResult = nil
            return
        }

        service.searchUser(username: searchText) { [weak self] user in
            DispatchQueue.main.async {
                self?.searchResult = user
            }
        }
    }

    // MARK: - SEND REQUEST
    func sendRequest(to user: UserModel) {
        guard let authUser = Auth.auth().currentUser else { return }

        // Load logged-in user from Firestore
        service.searchUser(username: authUser.uid) { _ in }

        // Instead get from AuthViewModel singleton (your actual logged in UserModel)
        guard let myUser = AuthViewModel().loggedInUser else { return }

        service.sendFriendRequest(to: user, from: myUser) { _ in }
    }

    // MARK: - REQUEST HANDLING
    func accept(request: FriendRequest) {
        guard let myUser = AuthViewModel().loggedInUser else { return }
        service.acceptRequest(request, currentUser: myUser) { _ in }
    }

    func delete(request: FriendRequest) {
        service.deleteRequest(request) { _ in }
    }

    // MARK: - REMOVE FRIEND
    func remove(friend: Friend) {
        service.removeFriend(friend) { _ in }
    }

    // MARK: - HELPER
    func hasPendingRequest(to user: UserModel) -> Bool {
        return requests.contains(where: { $0.fromUserID == user.id }) ||
               friends.contains(where: { $0.userID == user.id })
    }
}
