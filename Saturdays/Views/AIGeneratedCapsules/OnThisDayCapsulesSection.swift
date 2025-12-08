//
//  OnThisDayCapsulesSection.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/7/25.
//


import SwiftUI

struct OnThisDayCapsulesSection: View {
    let capsules: [GeneratedCapsuleModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("On This Day")
                .font(.title2.bold())
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(capsules) { cap in
                        NavigationLink {
                            GeneratedCapsuleDetailView(capsule: cap)
                        } label: {
                            VStack(alignment: .leading) {

                                GeneratedCapsuleThumbnailView(filename: cap.coverPhoto)
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                Text(cap.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)

                                Text("\(cap.photoCount) photos")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 120)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
