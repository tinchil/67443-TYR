//
//  GeneratedCapsulesSection.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/7/25.
//


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

            Text("Capsules Generated For You")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 6)

            if isLoading {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Analyzing your photos…")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 10)
            }

            if capsules.isEmpty && !isLoading {
                Text("No generated capsules yet.")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(capsules) { cap in
                            VStack(alignment: .leading) {
                                Image(cap.coverPhoto)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                Text(cap.name)
                                    .font(.headline)
                                    .lineLimit(1)

                                Text("\(cap.photoCount) photos")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 120)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
    }
}
