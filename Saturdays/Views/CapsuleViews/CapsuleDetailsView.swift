//
//  CapsuleDetailsView.swift
//  Saturdays
//
//  Created by Tin on 12/5/25.
//


import SwiftUI

struct CapsuleDetailsView: View {
    @ObservedObject var viewModel: CapsuleDetailsViewModel
    @State private var showChooseGroup = false
    @State private var revealDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var enableRevealDate = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Capsule Details")
                .font(.largeTitle)
                .bold()

            Text(viewModel.capsule.type == .memory ? "Memory Capsule" : "Letter Capsule")
                .font(.subheadline)
                .foregroundColor(.indigo)

            TextField("Capsule Name", text: $viewModel.capsule.name)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)

            // MARK: - REVEAL DATE TOGGLE
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Lock until reveal date", isOn: $enableRevealDate)
                    .font(.headline)

                if enableRevealDate {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Capsule will be locked until:")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        DatePicker("Reveal Date", selection: $revealDate, in: Date()..., displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)

                        Text("Members can add photos, but won't see the final video until this date.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            // MARK: - NEXT BUTTON
            Button {
                // Save reveal date to viewModel if enabled
                viewModel.capsule.revealDate = enableRevealDate ? revealDate : nil
                showChooseGroup = true
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.capsule.name.isEmpty ? Color.gray : Color(red: 0/255, green: 0/255, blue: 142/255))
                    .cornerRadius(12)
            }
            .disabled(viewModel.capsule.name.isEmpty)
            .padding(.top, 30)

            Spacer()
        }
        .padding()
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showChooseGroup) {
            ChooseGroupView(
                capsuleVM: viewModel,
                groupsVM: GroupsViewModel()
            )
        }
    }
}
