//
//  SuccessView.swift
//  Saturdays
//
//  Created by Claude Code
//

import SwiftUI

struct SuccessView: View {
    @Environment(\.dismiss) var dismiss
    @State private var navigateToHome = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Success Icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
            }

            // Success Message
            VStack(spacing: 12) {
                Text("Success!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your capsule has been created")
                    .font(.body)
                    .foregroundColor(.secondary)

                Text("Your friends have been notified")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Action Buttons
            VStack(spacing: 12) {
                Button(action: {
                    // Navigate to capsule view
                }) {
                    Text("View Capsule")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                NavigationLink(destination: HomePageView(), isActive: $navigateToHome) {
                    Button(action: {
                        navigateToHome = true
                    }) {
                        Text("Back to Home")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .navigationTitle("Success")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        SuccessView()
    }
}
