//
//  ChooseGroupView.swift
//  Saturdays
//
//  Created by Yining He  on 12/2/25.
//

import SwiftUI
import FirebaseAuth

struct ChooseGroupView: View {
    @ObservedObject var capsuleVM: CapsuleDetailsViewModel
    @StateObject var groupsVM: GroupsViewModel


    @State private var showSelectFriends = false
    @State private var selectedGroupID: String?
    @State private var navigateToPhotos = false

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 20) {

            // MARK: - HEADER
            Text("CHOOSE WHICH GROUP TO\nCREATE A CAPSULE FOR")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
                .padding(.horizontal)

            // MARK: - GROUPS GRID
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {

                    ForEach(groupsVM.groups) { group in
                        GroupCircleButton(
                            name: group.name,
                            memberCount: group.memberIDs.count,
                            isSelected: selectedGroupID == group.id
                        ) {
                            selectedGroupID = group.id
                            capsuleVM.setGroup(groupID: group.id, memberIDs: group.memberIDs)
                        }
                    }

                    NewGroupButton {
                        showSelectFriends = true
                    }
                }
                .padding()
            }

            // MARK: - CONTINUE BUTTON
            Button {
                navigateNext()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedGroupID != nil ? Color(red: 0/255, green: 0/255, blue: 142/255) : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(selectedGroupID == nil)
            .padding(.horizontal)
            .padding(.top, 10)

            Spacer()
        }
        .padding(.bottom, 160)   // ⭐ FINAL FIX
        .background(Color(red: 0.96, green: 0.96, blue: 1.0))
        .navigationTitle("Choose Group")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showSelectFriends) {
            SelectFriendsView(capsuleVM: capsuleVM, groupsVM: groupsVM)
        }
        .navigationDestination(isPresented: $navigateToPhotos) {
            if capsuleVM.capsule.type == .memory {
                AddPhotosView(capsuleVM: capsuleVM)
            } else {
                Text("Letter Editor Coming Soon")
                    .font(.title)
            }
        }
        .onAppear {
            groupsVM.loadGroups()
        }
    }


    func navigateNext() {
        navigateToPhotos = true
    }
}


// MARK: - Group Circle Component
struct GroupCircleButton: View {
    let name: String
    let memberCount: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(red: 212/255, green: 212/255, blue: 255/255))
                        .frame(width: 100, height: 100)

                    if isSelected {
                        Circle()
                            .strokeBorder(Color.blue, lineWidth: 3)
                            .frame(width: 100, height: 100)
                    }
                }

                Text(name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255))

                Text("\(memberCount) members")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - New Group Button Component
struct NewGroupButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .strokeBorder(Color(red: 0/255, green: 0/255, blue: 142/255), lineWidth: 2)
                        .background(Circle().fill(Color.white))
                        .frame(width: 100, height: 100)

                    Image(systemName: "plus")
                        .font(.system(size: 30))
                        .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255))
                }

                Text("New Group")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
