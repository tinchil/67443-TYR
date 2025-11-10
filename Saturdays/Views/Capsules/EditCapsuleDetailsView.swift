//
//  EditCapsuleDetailsView.swift
//  Saturdays
//
//  Created by Claude Code
//

import SwiftUI

struct EditCapsuleDetailsView: View {
    @ObservedObject var viewModel: CapsuleViewModel
    let groupId: UUID

    @State private var capsuleName: String = ""
    @State private var capsuleDescription: String = ""
    @State private var selectedType: CapsuleType = .memories
    @State private var revealDate: Date = Date()
    @State private var revealCycle: RevealCycle = .weekly
    @State private var lockPeriod: Date = Date()
    @State private var contributionRequirement: ContributionRequirement = .none
    @State private var showRevealDatePicker = false
    @State private var showLockPeriodPicker = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Capsule Details")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Edit your capsule settings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                // Capsule Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("What would like to name this capsule?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    TextField("Capsule name", text: $capsuleName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)

                // Capsule Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Capsule Description")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    TextEditor(text: $capsuleDescription)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(4)
                }
                .padding(.horizontal)

                // Capsule Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose Capsule Type")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        ForEach([CapsuleType.memories, CapsuleType.travel], id: \.self) { type in
                            Button(action: {
                                selectedType = type
                            }) {
                                HStack {
                                    if selectedType == type {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.gray)
                                    }
                                    Text(type.rawValue)
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(selectedType == type ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Set Reveal Date
                VStack(alignment: .leading, spacing: 8) {
                    Text("Set Reveal Date")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Button(action: {
                        showRevealDatePicker.toggle()
                    }) {
                        HStack {
                            Text(revealDate.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }

                    if showRevealDatePicker {
                        DatePicker("", selection: $revealDate, displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                }
                .padding(.horizontal)

                // Choose Reveal Cycle
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose Reveal Cycle")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Picker("Reveal Cycle", selection: $revealCycle) {
                        ForEach(RevealCycle.allCases, id: \.self) { cycle in
                            Text(cycle.rawValue).tag(cycle)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.horizontal)

                // Choose Lock Period
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose your Lock period:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Button(action: {
                        showLockPeriodPicker.toggle()
                    }) {
                        HStack {
                            Text(lockPeriod.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }

                    if showLockPeriodPicker {
                        DatePicker("", selection: $lockPeriod, displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                }
                .padding(.horizontal)

                // Contribution Requirement
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose Contribution Requirement")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    VStack(spacing: 8) {
                        ForEach(ContributionRequirement.allCases, id: \.self) { requirement in
                            Button(action: {
                                contributionRequirement = requirement
                            }) {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .stroke(contributionRequirement == requirement ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                                            .frame(width: 20, height: 20)

                                        if contributionRequirement == requirement {
                                            Circle()
                                                .fill(Color.blue)
                                                .frame(width: 10, height: 10)
                                        }
                                    }

                                    Text(requirement.rawValue)
                                        .foregroundColor(.primary)

                                    Spacer()

                                    if contributionRequirement == requirement {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 80)
            }
        }
        .navigationTitle("Capsule Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    saveChanges()
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
        }
        .onAppear {
            loadCapsuleData()
        }
    }

    // MARK: - Helper Methods

    private func loadCapsuleData() {
        guard let group = viewModel.getGroup(by: groupId),
              let capsule = group.capsule else { return }

        capsuleName = capsule.name
        capsuleDescription = capsule.description
        selectedType = capsule.type
        revealDate = capsule.revealDate
        revealCycle = capsule.revealCycle
        lockPeriod = capsule.lockPeriod
        contributionRequirement = capsule.contributionRequirement
    }

    private func saveChanges() {
        // Update the capsule in the ViewModel
        viewModel.updateCapsule(
            groupId: groupId,
            name: capsuleName,
            description: capsuleDescription,
            type: selectedType,
            revealDate: revealDate,
            revealCycle: revealCycle,
            lockPeriod: lockPeriod,
            contributionRequirement: contributionRequirement
        )
        // Dismiss the view
        dismiss()
    }
}

#Preview {
    NavigationStack {
        EditCapsuleDetailsView(viewModel: CapsuleViewModel(), groupId: SampleData.sampleGroups[0].id)
    }
}
