//
//  HomePageView.swift
//  Saturdays
//
//  Created by Claude Code
//

import SwiftUI

struct HomePageView: View {
    @StateObject private var groupCreationViewModel = GroupCreationViewModel()
    @StateObject private var capsuleViewModel = CapsuleViewModel()
    @State private var showGroupCreation = false
    @State private var showCapsules = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                // App Title
                Text("Saturdays")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Create and share memory capsules with friends")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                // Create Group Button
                Button(action: {
                    groupCreationViewModel.reset()
                    showGroupCreation = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create New Group")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 30)

                // Capsules Button
                Button(action: {
                    showCapsules = true
                }) {
                    HStack {
                        Image(systemName: "square.stack.3d.up.fill")
                        Text("Capsules")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 30)

                Spacer()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showGroupCreation) {
                SelectFriendsView(viewModel: groupCreationViewModel)
            }
            .navigationDestination(isPresented: $showCapsules) {
                CapsuleListView(viewModel: capsuleViewModel)
            }
        }
    }
}

#Preview {
    HomePageView()
}
