//
//  GroupCreatedSuccessView.swift
//  Saturdays
//
//  Created by Tin on 12/5/25.
//


import SwiftUI

struct GroupCreatedSuccessView: View {
    @ObservedObject var capsuleVM: CapsuleDetailsViewModel
    @State var navigateToNext = false
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
            Text("Group Created!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToNext) {
            // Navigate based on capsule type
            if capsuleVM.capsule.type == .memory {
                AddPhotosView(capsuleVM: capsuleVM)
            } else {
                // TODO: LetterEditorView (not created yet)
                Text("Letter Editor Coming Soon")
                    .font(.title)
            }
        }
        .onAppear {
            // Auto-navigate after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                navigateToNext = true
            }
        }
    }
}

#Preview {
    GroupCreatedSuccessView(capsuleVM: CapsuleDetailsViewModel(capsule: CapsuleModel(type: .memory)))
}
