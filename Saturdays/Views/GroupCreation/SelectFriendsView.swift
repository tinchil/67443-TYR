//
//  SelectFriendsView.swift
//  Saturdays
//
//  Created by Tin on 12/5/25.
//


import SwiftUI
import FirebaseAuth

struct SelectFriendsView: View {
    @ObservedObject var capsuleVM: CapsuleDetailsViewModel
    @ObservedObject var groupsVM: GroupsViewModel
    @StateObject var friendsVM = FriendsViewModel()

    // In SelectFriendsView.swift
    @State var selectedFriendIDs: Set<String> = []  // Remove 'private'
    @State var searchText: String = ""              // Remove 'private'
    @State var groupName: String = ""               // Remove 'private'
    @State var showGroupNameAlert = false           // Remove 'private'
    @State var showSuccessView = false              // Remove 'private'
    @Environment(\.dismiss) var dismiss

    var filteredFriends: [Friend] {
        if searchText.isEmpty {
            return friendsVM.friends
        } else {
            return friendsVM.friends.filter { friend in
                friend.username.lowercased().contains(searchText.lowercased()) ||
                friend.displayName.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - HEADER
            Text("SELECT FRIENDS TO CREATE\nNEW CAPSULE GROUP")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
                .padding(.horizontal)

            // MARK: - SEARCH BAR
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField("Search Friend...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 20)

            // MARK: - FRIENDS LIST
            if friendsVM.friends.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                        .padding(.top, 60)

                    Text("No friends yet")
                        .font(.headline)
                        .foregroundColor(.gray)

                    Text("Add friends first to create a group")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(filteredFriends) { friend in
                            FriendSelectionRow(
                                friend: friend,
                                isSelected: selectedFriendIDs.contains(friend.userID)
                            ) {
                                toggleSelection(friend.userID)
                            }

                            if friend.id != filteredFriends.last?.id {
                                Divider()
                                    .padding(.leading, 80)
                            }
                        }
                    }
                }
                .padding(.top, 10)
            }

            // MARK: - CREATE GROUP BUTTON
            if !selectedFriendIDs.isEmpty {
                Button {
                    showGroupNameAlert = true
                } label: {
                    Text("Create Group with \(selectedFriendIDs.count) friend(s)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0/255, green: 0/255, blue: 142/255))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }

            Spacer()
        }
        .padding(.bottom, 160)   // ⭐ FIX: moves entire view above tab bar
        .background(Color.white)
        .navigationTitle("Select Friends")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AddFriendView(vm: friendsVM)
                } label: {
                    Image(systemName: "person.badge.plus")
                        .font(.title2)
                        .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255))
                }
            }
        }
        .navigationDestination(isPresented: $showSuccessView) {
            GroupCreatedSuccessView(capsuleVM: capsuleVM)
        }
        .alert("Name Your Group", isPresented: $showGroupNameAlert) {
            TextField("Group Name", text: $groupName)
            Button("Cancel", role: .cancel) { }
            Button("Create") {
                createGroup()
            }
        } message: {
            Text("Give your new group a name")
        }
    }

    // MARK: - HELPERS
    func toggleSelection(_ friendID: String) {
        if selectedFriendIDs.contains(friendID) {
            selectedFriendIDs.remove(friendID)
        } else {
            selectedFriendIDs.insert(friendID)
        }
    }

    func createGroup() {
        guard !groupName.isEmpty else { return }
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        var memberIDs = Array(selectedFriendIDs)
        memberIDs.append(currentUserID)  // Add yourself to the group

        // Create group in GroupsService
        groupsVM.createGroup(name: groupName, memberIDs: memberIDs) { groupID in
            if let groupID = groupID {
                // Set the group in capsule
                capsuleVM.setGroup(groupID: groupID, memberIDs: memberIDs)
                // Show success view (will auto-navigate after 2 seconds)
                showSuccessView = true
            }
        }
    }
}

// MARK: - Friend Selection Row Component
struct FriendSelectionRow: View {
    let friend: Friend
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Profile Icon
                ZStack {
                    Circle()
                        .fill(Color(UIColor.systemGray4))
                        .frame(width: 50, height: 50)

                    Image(systemName: "person.fill")
                        .foregroundColor(Color(UIColor.systemGray2))
                        .font(.system(size: 24))
                }

                // Names
                VStack(alignment: .leading, spacing: 2) {
                    Text(friend.username)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)

                    Text(friend.displayName)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }

                Spacer()

                // Checkbox
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                } else {
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue.opacity(0.05) : Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
