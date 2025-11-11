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
                    capsule.coverPhoto.map { img in
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 240, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                )
            
            Text(capsule.name.isEmpty ? "Untitled Capsule" : capsule.name)
                .font(.headline)
        }
        .frame(width: 240)
    }
}
