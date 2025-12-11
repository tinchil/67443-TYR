//
//  CapsuleCreatedSuccessView.swift
//  Saturdays
//
//  Created by Claude Code
//

import SwiftUI

struct CapsuleCreatedSuccessView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Checkmark Circle
            ZStack {
                Circle()
                    .fill(Color(red: 0/255, green: 0/255, blue: 142/255))
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
            }

            // Success Text
            Text("Capsule Created!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
//        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Auto-dismiss after 2 seconds and go back to home
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // Post notification to pop entire navigation stack back to home
                NotificationCenter.default.post(name: NSNotification.Name("DismissCapsuleFlow"), object: nil)
            }
        }
    }
}

#Preview {
    CapsuleCreatedSuccessView()
}
