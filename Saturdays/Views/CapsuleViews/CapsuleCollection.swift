//
//  CapsuleCollection.swift
//  Saturdays
//
//  Created by Yining He  on 12/1/25.
//

import SwiftUI

struct CapsuleCollection: View {

    @State private var groupedCapsules: [String: (groupName: String, capsules: [CapsuleModel])] = [:]
    @State private var groups: [GroupModel] = []
    @State private var isLoading = true

    private let capsuleService = CapsuleService()
    private let groupsService = GroupsService()

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.white, Color(red: 0.94, green: 0.95, blue: 1.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        // MARK: - HEADER
                        HStack {
                            Text("Your Capsules")
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            Spacer()

                            Image(systemName: "sparkles")
                                .font(.title3)
                        }
                        .padding(.horizontal)
                        .padding(.top)

                        // MARK: - CAPSULES BY GROUP
                        if isLoading {
                            ProgressView("Loading capsules...")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                        } else if groupedCapsules.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.5))

                                Text("No capsules yet")
                                    .font(.title2)
                                    .fontWeight(.semibold)

                                Text("Create your first memory capsule!")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        } else {
                            // Display capsules grouped by group
                            ForEach(groups.filter { groupedCapsules[$0.id]?.capsules.isEmpty == false }, id: \.id) { group in
                                VStack(alignment: .leading, spacing: 12) {
                                    // Group name header
                                    Text(group.name)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.8))
                                        .padding(.horizontal)

                                    // Horizontal scrolling carousel of capsules
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            if let capsules = groupedCapsules[group.id]?.capsules {
                                                ForEach(capsules) { capsule in
                                                    NavigationLink(destination: CapsuleDetailView(capsule: capsule)) {
                                                        CapsuleCarouselCard(capsule: capsule)
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .onAppear {
                loadCapsules()
            }
        }
    }

    // MARK: - LOAD CAPSULES
    private func loadCapsules() {
        isLoading = true

        // First fetch user's groups
        groupsService.fetchUserGroups { fetchedGroups in
            self.groups = fetchedGroups

            // Then fetch all capsules
            capsuleService.fetchUserCapsules { fetchedCapsules in
                // Group capsules by groupID
                var grouped: [String: (groupName: String, capsules: [CapsuleModel])] = [:]

                for group in fetchedGroups {
                    let capsulesForGroup = fetchedCapsules.filter { $0.groupID == group.id }
                    grouped[group.id] = (groupName: group.name, capsules: capsulesForGroup)
                }

                self.groupedCapsules = grouped
                self.isLoading = false
            }
        }
    }
}

// MARK: - CAPSULE CAROUSEL CARD
struct CapsuleCarouselCard: View {
    let capsule: CapsuleModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Capsule image (circular)
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 160, height: 160)
                    .shadow(radius: 4)

                if let coverPhotoURL = capsule.coverPhotoURL {
                    AsyncImage(url: URL(string: coverPhotoURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 160, height: 160)
                    .clipShape(Circle())
                } else if let firstMediaURL = capsule.mediaURLs.first {
                    AsyncImage(url: URL(string: firstMediaURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 160, height: 160)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 160, height: 160)
                }
            }

            // Capsule name
            Text(capsule.name.isEmpty ? "Untitled" : capsule.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
                .frame(width: 160)
        }
        .frame(width: 160)
    }
}
                     
#Preview {
    CapsuleCollection()
}


