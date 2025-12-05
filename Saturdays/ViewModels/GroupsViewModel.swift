//
//  GroupsViewModel.swift
//  Saturdays
//
//  Created by Tin 12/2/2025
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class GroupsViewModel: ObservableObject {

    @Published var groups: [GroupModel] = []

    private let service = GroupsService()

    // FIREBASE LISTENER (will be nil in mock mode)
    private var groupsListener: ListenerRegistration?

    init() {
        // Load groups when initialized
        loadGroups()
    }

    deinit {
        removeListeners()
    }

    // MARK: - LOAD GROUPS
    func loadGroups() {
        // For mock mode, just fetch once
        service.fetchUserGroups { [weak self] groups in
            DispatchQueue.main.async {
                self?.groups = groups
            }
        }

        // Alternatively, attach listener (will be nil in mock mode)
        // attachListeners()
    }

    // MARK: - CREATE GROUP
    func createGroup(name: String, memberIDs: [String], completion: @escaping (String?) -> Void) {
        service.createGroup(name: name, memberIDs: memberIDs) { [weak self] groupID in
            DispatchQueue.main.async {
                // Reload groups after creating
                self?.loadGroups()
                completion(groupID)
            }
        }
    }

    // MARK: - DELETE GROUP
    func deleteGroup(_ group: GroupModel) {
        service.deleteGroup(group) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.loadGroups()
                }
            }
        }
    }

    // MARK: - LISTENERS (Like FriendsViewModel)
    func attachListeners() {
        removeListeners()

        groupsListener = service.listenForGroups { [weak self] groups in
            DispatchQueue.main.async {
                self?.groups = groups
            }
        }
    }

    func removeListeners() {
        groupsListener?.remove()
        groupsListener = nil
    }
}
