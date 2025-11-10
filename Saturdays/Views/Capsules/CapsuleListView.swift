//
//  CapsuleListView.swift
//  Saturdays
//
//  Created by Claude Code
//

import SwiftUI

struct CapsuleListView: View {
    @ObservedObject var viewModel: CapsuleViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Tabs for Personal/Group
            HStack(spacing: 0) {
                Button(action: {}) {
                    Text("Personal")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }

                Button(action: {}) {
                    Text("Group")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // Capsule List
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.groups) { group in
                        NavigationLink(destination: CapsuleDetailView(viewModel: viewModel, groupId: group.id)) {
                            CapsuleCard(group: group)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }

            Spacer()

            // Bottom Navigation (placeholder)
            HStack {
                Button(action: {}) {
                    VStack(spacing: 4) {
                        Image(systemName: "house.fill")
                        Text("Home")
                            .font(.caption2)
                    }
                }
                .frame(maxWidth: .infinity)

                Button(action: {}) {
                    VStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                        Text("Create New")
                            .font(.caption2)
                    }
                }
                .frame(maxWidth: .infinity)

                Button(action: {}) {
                    VStack(spacing: 4) {
                        Image(systemName: "rectangle.stack.fill")
                        Text("Capsules")
                            .font(.caption2)
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.blue)
            }
            .padding(.vertical, 8)
            .background(Color(UIColor.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(.gray.opacity(0.3)),
                alignment: .top
            )
        }
        .navigationTitle("Your Capsules")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CapsuleCard: View {
    let group: Group

    var isLocked: Bool {
        guard let capsule = group.capsule else { return true }
        return capsule.lockPeriod > Date()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with group name
            HStack {
                Text(group.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                if !isLocked {
                    Text("• New Capsule")
                        .font(.caption)
                        .foregroundColor(.blue)
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 12)

            // Photo Grid
            if let capsule = group.capsule {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 4) {
                    ForEach(Array(capsule.photos.prefix(6).enumerated()), id: \.offset) { index, photo in
                        Image(uiImage: photo.image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 100)
                            .clipped()
                            .overlay(
                                isLocked ? Color.black.opacity(0.3) : Color.clear
                            )
                            .overlay(
                                isLocked && index == 0 ?
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.white)
                                    .font(.title)
                                : nil
                            )
                    }
                }

                // Capsule Info
                HStack {
                    Text(capsule.name)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Locked till \(capsule.lockPeriod.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("Reveal on \(capsule.revealDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        CapsuleListView(viewModel: CapsuleViewModel())
    }
}
