//
//  CapsuleCardView.swift
//  Saturdays
//
//  Created by Yining He  on 12/1/25.
//

import SwiftUI

struct CapsuleCardView: View {
    let capsule: CapsuleModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .frame(width: 240, height: 200)
                .shadow(radius: 6)
                .overlay(
                    Group {
                        if let coverPhotoURL = capsule.coverPhotoURL {
                            AsyncImage(url: URL(string: coverPhotoURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 240, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        } else if let firstMediaURL = capsule.mediaURLs.first {
                            // Use first media as fallback
                            AsyncImage(url: URL(string: firstMediaURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 240, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        } else {
                            Color.gray.opacity(0.2)
                        }
                    }
                )

            Text(capsule.name.isEmpty ? "Untitled Capsule" : capsule.name)
                .font(.headline)
        }
        .frame(width: 240)
    }
}
