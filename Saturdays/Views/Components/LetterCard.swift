//
//  LetterCard.swift
//  Saturdays
//
//  Created by Yining He  on 11/30/25.
//

import SwiftUI

struct LetterCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 3)
                .frame(width: 150, height: 150)
                .overlay(
                    Image(systemName: "pencil.and.scribble")
                        .font(.system(size: 44))
                        .foregroundColor(.black.opacity(0.7))
                )
        }
    }
}
