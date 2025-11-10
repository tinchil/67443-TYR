//
//  GroupDetailsView.swift
//  Saturdays
//
//  Created by Claude Code
//

import SwiftUI

struct GroupDetailsView: View {
    @ObservedObject var viewModel: GroupCreationViewModel
    @State private var navigateToCapsuleDetails = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Group Details")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("What is this group called?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 20)

            // Group Name Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Group Name")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                TextField("Enter Group Name", text: $viewModel.groupName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }
            .padding(.top, 30)

            // Selected Members Preview
            VStack(alignment: .leading, spacing: 12) {
                Text("Members (\(viewModel.selectedFriends.count))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.selectedFriends) { friend in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Text(String(friend.name.prefix(1)))
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    )

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(friend.name)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    Text(friend.username)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            .padding(.top, 30)

            Spacer()

            // Next Button
            Button(action: {
                navigateToCapsuleDetails = true
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canProceedFromGroupDetails ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!viewModel.canProceedFromGroupDetails)
            .padding()
        }
        .navigationTitle("Group Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToCapsuleDetails) {
            CapsuleDetailsView(viewModel: viewModel)
        }
    }
}

#Preview {
    NavigationStack {
        GroupDetailsView(viewModel: GroupCreationViewModel())
    }
}
