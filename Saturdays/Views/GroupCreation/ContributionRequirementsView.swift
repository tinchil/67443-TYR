//
//  ContributionRequirementsView.swift
//  Saturdays
//
//  Created by Claude Code
//

//import SwiftUI
//
//struct ContributionRequirementsView: View {
//    @ObservedObject var viewModel: GroupCreationViewModel
//    @State private var navigateToAddPhotos = false
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // Header
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Contribution Requirements")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                Text("Choose how often members should contribute")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.horizontal)
//            .padding(.top, 20)
//
//            // Requirement Options
//            ScrollView {
//                VStack(spacing: 0) {
//                    ForEach(ContributionRequirement.allCases, id: \.self) { requirement in
//                        RequirementRow(
//                            requirement: requirement,
//                            isSelected: viewModel.contributionRequirement == requirement
//                        ) {
//                            viewModel.contributionRequirement = requirement
//                        }
//
//                        if requirement != ContributionRequirement.allCases.last {
//                            Divider()
//                                .padding(.leading, 20)
//                        }
//                    }
//                }
//                .padding(.top, 20)
//            }
//
//            // Next Button
//            Button(action: {
//                navigateToAddPhotos = true
//            }) {
//                Text("Next")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .cornerRadius(12)
//            }
//            .padding()
//        }
//        .navigationTitle("Contribution Requirements")
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationDestination(isPresented: $navigateToAddPhotos) {
//            AddPhotosView(viewModel: viewModel)
//        }
//    }
//}
//
//struct RequirementRow: View {
//    let requirement: ContributionRequirement
//    let isSelected: Bool
//    let action: () -> Void
//
//    var requirementDescription: String {
//        switch requirement {
//        case .none:
//            return "No contribution requirements"
//        case .minimum:
//            return "Minimum 1 photo per week"
//        case .maximum:
//            return "Maximum 10 photos per week"
//        case .weekly:
//            return "Weekly contribution required"
//        case .custom:
//            return "Set custom contribution rules"
//        }
//    }
//
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 16) {
//                // Radio button
//                ZStack {
//                    Circle()
//                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
//                        .frame(width: 24, height: 24)
//
//                    if isSelected {
//                        Circle()
//                            .fill(Color.blue)
//                            .frame(width: 12, height: 12)
//                    }
//                }
//
//                // Requirement Info
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(requirement.rawValue)
//                        .font(.body)
//                        .fontWeight(.medium)
//                        .foregroundColor(.primary)
//                    Text(requirementDescription)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//
//                Spacer()
//            }
//            .padding()
//            .contentShape(Rectangle())
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//}
//
//#Preview {
//    NavigationStack {
//        ContributionRequirementsView(viewModel: GroupCreationViewModel())
//    }
//}
