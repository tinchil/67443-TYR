//
//  SelectFriendsView.swift
//  Saturdays
//
//  Created by Claude Code
//

import SwiftUI

struct SelectFriendsView: View {
    @ObservedObject var viewModel: GroupCreationViewModel
    @State private var navigateToGroupDetails = false
    let friends = Friend.sampleFriends

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Select friends to create")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("new capsule group")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 20)

            // Friend List
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(friends) { friend in
                        FriendRow(
                            friend: friend,
                            isSelected: viewModel.selectedFriends.contains(friend)
                        ) {
                            toggleSelection(friend)
                        }
                        Divider()
                            .padding(.leading, 60)
                    }
                }
                .padding(.top, 20)
            }

            // Create Group Button
            Button(action: {
                navigateToGroupDetails = true
            }) {
                Text("Create Group")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canProceedFromFriendSelection ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!viewModel.canProceedFromFriendSelection)
            .padding()
        }
        .navigationTitle("Select Friends")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToGroupDetails) {
            GroupDetailsView(viewModel: viewModel)
        }
    }

    private func toggleSelection(_ friend: Friend) {
        if let index = viewModel.selectedFriends.firstIndex(of: friend) {
            viewModel.selectedFriends.remove(at: index)
        } else {
            viewModel.selectedFriends.append(friend)
        }
    }
}

struct FriendRow: View {
    let friend: Friend
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(friend.name.prefix(1)))
                            .font(.headline)
                            .foregroundColor(.white)
                    )

                // Name and Username
                VStack(alignment: .leading, spacing: 2) {
                    Text(friend.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Text(friend.username)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                } else {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        SelectFriendsView(viewModel: GroupCreationViewModel())
    }
}
