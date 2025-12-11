//
//  RevealSettingsView.swift
//  Saturdays
//

import SwiftUI
import Combine

struct RevealSettingsView: View {
    @ObservedObject var capsuleVM: CapsuleDetailsViewModel

    @State private var revealDate = Date()
    @State private var minContributions: Int = 0
    @State private var navigateToContent = false

    var body: some View {
        VStack(spacing: 30) {

            Text("Set Reveal Options")
                .font(.largeTitle.bold())

            // MARK: - REVEAL DATE
            VStack(alignment: .leading, spacing: 12) {
                Text("Reveal Date")
                    .font(.headline)

                DatePicker(
                    "Unlocks On",
                    selection: $revealDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
            }
            .padding(.horizontal)

            // MARK: - CONTRIBUTION REQUIREMENT (Memory Capsules Only)
            if capsuleVM.capsule.type == .memory {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Minimum Contributions (optional)")
                        .font(.headline)

                    Picker("Requirement", selection: $minContributions) {
                        Text("None").tag(0)
                        Text("1 Photo Each").tag(1)
                        Text("3 Photos Each").tag(3)
                        Text("5 Photos Each").tag(5)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)
            }

            // MARK: - CONTINUE
            Button {
                capsuleVM.capsule.revealDate = revealDate

                // Only set minContribution for memory capsules
                if capsuleVM.capsule.type == .memory {
                    capsuleVM.capsule.minContribution =
                        (minContributions == 0 ? nil : minContributions)
                } else {
                    capsuleVM.capsule.minContribution = nil
                }

                navigateToContent = true
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth:.infinity)
                    .padding()
                    .background(Color(red: 0/255, green: 0/255, blue: 142/255))
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Reveal Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToContent) {
            // Route based on capsule type
            if capsuleVM.capsule.type == .memory {
                AddPhotosView(capsuleVM: capsuleVM)
            } else {
                AddLettersView(capsuleVM: capsuleVM)
            }
        }
    }
}
