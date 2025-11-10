//
//  CapsuleDetailView.swift
//  Saturdays
//
//  Created by Claude Code
//

import SwiftUI

struct CapsuleDetailView: View {
    @ObservedObject var viewModel: CapsuleViewModel
    let groupId: UUID
    @State private var showEditCapsule = false

    var group: Group? {
        viewModel.getGroup(by: groupId)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Capsule Info Header
                if let group = group, let capsule = group.capsule {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(capsule.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(capsule.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack {
                            Label("\(group.members.count) members", systemImage: "person.2")
                            Spacer()
                            Text(capsule.revealDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    }
                    .padding()

                    Divider()

                    // Photo Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Contributions")
                            .font(.headline)
                            .padding(.horizontal)

                        Text("\(capsule.contributionRequirement.rawValue) contributions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(Array(capsule.photos.enumerated()), id: \.offset) { index, photo in
                                Image(uiImage: photo.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 120)
                                    .clipped()
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Divider()
                        .padding(.top)

                    // Capsule Details Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Capsule Details")
                            .font(.headline)

                        DetailRow(label: "Type", value: capsule.type.rawValue)
                        DetailRow(label: "Reveal Cycle", value: capsule.revealCycle.rawValue)
                        DetailRow(label: "Lock Period", value: capsule.lockPeriod.formatted(date: .abbreviated, time: .omitted))
                        DetailRow(label: "Contribution Requirement", value: capsule.contributionRequirement.rawValue)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(group?.name ?? "Capsule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showEditCapsule = true
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationDestination(isPresented: $showEditCapsule) {
            EditCapsuleDetailsView(viewModel: viewModel, groupId: groupId)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationStack {
        CapsuleDetailView(viewModel: CapsuleViewModel(), groupId: SampleData.sampleGroups[0].id)
    }
}
