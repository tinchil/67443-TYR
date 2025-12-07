//
//  GeneratedCapsulesSection.swift
//  Saturdays
//

import SwiftUI

struct GeneratedCapsulesSection: View {
    let capsules: [GeneratedCapsuleModel]
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Your Memories, Organized into Events")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 6)

            // Loading indicator
            if isLoading {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Analyzing your photos and grouping them into events…")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 10)
            }

            // No capsules yet (done loading)
            if capsules.isEmpty && !isLoading {
                Text("No event capsules yet — keep capturing moments!")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {

                        ForEach(capsules) { cap in
                            NavigationLink {
                                GeneratedCapsuleDetailView(capsule: cap)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {

                                    GeneratedCapsuleThumbnailView(filename: cap.coverPhoto)
                                        .frame(width: 120, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .contentShape(Rectangle())

                                    Text(cap.name)
                                        .font(.headline)
                                        .lineLimit(1)
                                        .foregroundColor(.primary)

                                    Text("\(cap.photoCount) photos")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 120)
                            }
                            .buttonStyle(.plain)    // Prevents weird blue highlight
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
    }
}

