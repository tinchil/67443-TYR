//
//  PromptCard.swift
//  Saturdays
//
//  Created by Yining He  on 11/30/25.
//

import SwiftUI

struct PromptCard: View {
    let prompt: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Prompt of the Day ⭐")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(prompt)
                    .font(.headline)
            }
            
            Spacer()
            
            Button(action: {
                print("Edit tapped")
            }) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 44, height: 44)
                    .shadow(radius: 2)
                    .overlay(
                        Image(systemName: "pencil")
                            .foregroundColor(.black)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(red: 0.88, green: 0.90, blue: 1))
        .cornerRadius(13)
        .shadow(radius: 4)
    }
}

