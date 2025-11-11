//import SwiftUI
//
//struct PhotoConfirmationView: View {
//    @ObservedObject var viewModel: GroupCreationViewModel
//    @State private var navigateToSuccess = false
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // Header
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Confirm Photos")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                Text("Review your selected photos")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.horizontal)
//            .padding(.top, 20)
//
//            // Photo Count
//            Text("\(viewModel.selectedPhotos.count) photo\(viewModel.selectedPhotos.count == 1 ? "" : "s") selected")
//                .font(.caption)
//                .foregroundColor(.secondary)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal)
//                .padding(.top, 8)
//
//            // Photos Grid
//            ScrollView {
//                LazyVGrid(columns: [
//                    GridItem(.flexible()),
//                    GridItem(.flexible()),
//                    GridItem(.flexible())
//                ], spacing: 10) {
//                    ForEach(Array(viewModel.selectedPhotos.enumerated()), id: \.offset) { _, photo in
//                        Image(uiImage: photo)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 100, height: 100)
//                            .clipped()
//                            .cornerRadius(8)
//                    }
//                }
//                .padding()
//            }
//
//            // Summary Card
//            VStack(alignment: .leading, spacing: 12) {
//                Text("Capsule Summary")
//                    .font(.headline)
//                    .padding(.horizontal)
//
//                VStack(spacing: 8) {
//                    SummaryRow(label: "Group", value: viewModel.groupName)
//                    SummaryRow(label: "Capsule", value: viewModel.capsuleName)
//                    SummaryRow(label: "Type", value: viewModel.selectedType.rawValue)
//                    SummaryRow(label: "Members", value: "\(viewModel.selectedFriends.count) people")
//                    SummaryRow(label: "Reveal Date", value: viewModel.revealDate.formatted(date: .abbreviated, time: .omitted))
//                }
//                .padding()
//                .background(Color.gray.opacity(0.05))
//                .cornerRadius(12)
//                .padding(.horizontal)
//            }
//            .padding(.vertical)
//
//            // Confirm Button
//            Button(action: {
//                navigateToSuccess = true
//            }) {
//                Text("Confirm & Create")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .cornerRadius(12)
//            }
//            .padding()
//        }
//        .navigationTitle("Confirm Photos")
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationDestination(isPresented: $navigateToSuccess) {
//            SuccessDestinationView(viewModel: viewModel)
//        }
//    }
//}
//
///// Extracted helper View to fix buildExpression issue
//private struct SuccessDestinationView: View {
//    @ObservedObject var viewModel: GroupCreationViewModel
//
//    var body: some View {
//        let newGroup = viewModel.createGroup()
//        let capsuleViewModel = CapsuleViewModel()
//        capsuleViewModel.addGroup(newGroup)
//
//        return SuccessView(
//            capsuleViewModel: capsuleViewModel,
//            newGroupId: newGroup.id
//        )
//    }
//}
//
//struct SummaryRow: View {
//    let label: String
//    let value: String
//
//    var body: some View {
//        HStack {
//            Text(label)
//                .font(.caption)
//                .foregroundColor(.secondary)
//            Spacer()
//            Text(value)
//                .font(.caption)
//                .fontWeight(.medium)
//        }
//    }
//}
//
//#Preview {
//    NavigationStack {
//        PhotoConfirmationView(viewModel: GroupCreationViewModel())
//    }
//}
