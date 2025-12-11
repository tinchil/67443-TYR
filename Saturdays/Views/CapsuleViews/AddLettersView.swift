//
//  AddLettersView.swift
//  Saturdays
//
//  Created for Letter Capsule feature
//

import SwiftUI
import FirebaseAuth

struct AddLettersView: View {
    @ObservedObject var capsuleVM: CapsuleDetailsViewModel
    var existingCapsule: CapsuleModel? = nil  // If provided, we're adding to an existing capsule
    var onLetterAdded: (([LetterModel]) -> Void)? = nil  // Callback when letter is added to existing capsule

    @State private var letterText: String = ""
    @State private var showSuccessView = false
    @State private var isSaving = false
    @State private var currentUserName: String = "Anonymous"
    @Environment(\.dismiss) var dismiss

    private let capsuleService = CapsuleService()

    private var isAddingToExisting: Bool {
        existingCapsule != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // MARK: - HEADER
            Text(isAddingToExisting ? "ADD YOUR LETTER" : "ADD LETTERS")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255))
                .padding(.horizontal)
                .padding(.top, 20)

            // MARK: - DESCRIPTION
            Text(isAddingToExisting
                ? "Write a message to add to this letter capsule."
                : "Write messages or letters to your group or future self. Everyone in the group can add their own letters.")
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255))
                .padding(.horizontal)

            // MARK: - LETTER TEXT EDITOR
            VStack(alignment: .leading, spacing: 8) {
                Text("Write Your Letter")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal)

                TextEditor(text: $letterText)
                    .frame(minHeight: 150)
                    .padding(12)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0/255, green: 0/255, blue: 142/255).opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)

                Text("\(letterText.count) characters")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }

            // MARK: - DONE BUTTON
            Button {
                createCapsule()
            } label: {
                if isSaving {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Saving...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(12)
                } else {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canFinish ? Color.black : Color.gray)
                        .cornerRadius(12)
                }
            }
            .disabled(!canFinish || isSaving)
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 30)

            Spacer()
        }
        .padding(.bottom, 160)
        .background(Color.white)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showSuccessView) {
            CapsuleCreatedSuccessView()
        }
        .onAppear {
            loadCurrentUserName()
        }
    }

    // MARK: - Computed Properties
    private var canFinish: Bool {
        return !letterText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Create Capsule OR Add Letter to Existing
    func createCapsule() {
        isSaving = true

        // Create letter from current text
        let trimmedText = letterText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            isSaving = false
            return
        }

        let newLetter = LetterModel(
            authorID: Auth.auth().currentUser?.uid ?? "",
            authorName: currentUserName,
            message: trimmedText,
            createdAt: Date()
        )

        // If adding to existing capsule
        if let existing = existingCapsule {
            print("✉️ Adding 1 letter to existing capsule: \(existing.id)")

            // Combine with existing letters
            let updatedLetters = existing.letters + [newLetter]

            // Update capsule with combined letters
            capsuleService.updateCapsuleLetters(capsuleID: existing.id, letters: updatedLetters) { success in
                isSaving = false

                if success {
                    print("✅ Added 1 new letter to capsule")

                    // Call the callback to notify parent view
                    onLetterAdded?(updatedLetters)

                    dismiss()
                } else {
                    print("❌ Failed to update capsule letters")
                }
            }
            return
        }

        // Otherwise, create new capsule
        guard let groupID = capsuleVM.selectedGroupID else {
            print("❌ No group selected")
            isSaving = false
            return
        }

        // Create the capsule in Firestore with the single letter
        capsuleService.createCapsule(
            name: capsuleVM.capsule.name,
            type: capsuleVM.capsule.type,
            groupID: groupID,
            mediaURLs: [],
            letters: [newLetter],
            revealDate: capsuleVM.capsule.revealDate,
            minContribution: capsuleVM.capsule.minContribution
        ) { capsuleID in
            isSaving = false

            guard let capsuleID = capsuleID else {
                print("❌ Failed to create letter capsule")
                return
            }

            print("✅ Letter capsule created with ID: \(capsuleID)")
            showSuccessView = true
        }
    }

    // MARK: - Load Current User Name
    private func loadCurrentUserName() {
        // Try to get user's display name from Firebase Auth
        if let displayName = Auth.auth().currentUser?.displayName, !displayName.isEmpty {
            currentUserName = displayName
        } else if let email = Auth.auth().currentUser?.email {
            // Use email prefix as fallback
            currentUserName = String(email.split(separator: "@").first ?? "Anonymous")
        }
    }
}

#Preview {
    AddLettersView(capsuleVM: CapsuleDetailsViewModel(capsule: CapsuleModel(type: .letter)))
}
