//
//  CapsuleDetailsView.swift
//  Saturdays
//
//  Created by Claude Code
//

import SwiftUI

struct CapsuleDetailsView: View {
    @ObservedObject var viewModel: GroupCreationViewModel
    @State private var showRevealDatePicker = false
    @State private var showLockPeriodPicker = false
    @State private var navigateToContributions = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Capsule Details")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Set up your memory capsule")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                // Capsule Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Capsule Name")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextField("Enter capsule name", text: $viewModel.capsuleName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)

                // Capsule Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Capsule Description")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextEditor(text: $viewModel.capsuleDescription)
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
                    Text("Capsule Type")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Picker("Capsule Type", selection: $viewModel.selectedType) {
                        ForEach(CapsuleType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal)

                // Reveal Date
                VStack(alignment: .leading, spacing: 8) {
                    Text("Set Reveal Date")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button(action: {
                        showRevealDatePicker.toggle()
                    }) {
                        HStack {
                            Text(viewModel.revealDate.formatted(date: .abbreviated, time: .omitted))
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
                        DatePicker("", selection: $viewModel.revealDate, displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                }
                .padding(.horizontal)

                // Reveal Cycle
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose Reveal Cycle")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Picker("Reveal Cycle", selection: $viewModel.revealCycle) {
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

                // Lock Period
                VStack(alignment: .leading, spacing: 8) {
                    Text("Lock period until")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button(action: {
                        showLockPeriodPicker.toggle()
                    }) {
                        HStack {
                            Text(viewModel.lockPeriod.formatted(date: .abbreviated, time: .omitted))
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
                        DatePicker("", selection: $viewModel.lockPeriod, displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 80)
            }
        }
        .safeAreaInset(edge: .bottom) {
            // Next Button
            Button(action: {
                navigateToContributions = true
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canProceedFromCapsuleDetails ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!viewModel.canProceedFromCapsuleDetails)
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .navigationTitle("Capsule Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToContributions) {
            ContributionRequirementsView(viewModel: viewModel)
        }
    }
}

#Preview {
    NavigationStack {
        CapsuleDetailsView(viewModel: GroupCreationViewModel())
    }
}
