//import SwiftUI
//
//struct SuccessView: View {
//    @ObservedObject var capsuleViewModel: CapsuleViewModel
//    let newGroupId: UUID
//    @Environment(\.dismiss) var dismiss
//
//    @State private var navigateToCapsule = false
//    @State private var navigateToHome = false
//
//    var body: some View {
//        VStack(spacing: 30) {
//            Spacer()
//
//            // Success Icon
//            ZStack {
//                Circle()
//                    .fill(Color.green.opacity(0.1))
//                    .frame(width: 120, height: 120)
//                Image(systemName: "checkmark.circle.fill")
//                    .font(.system(size: 80))
//                    .foregroundColor(.green)
//            }
//
//            // Success Message
//            VStack(spacing: 12) {
//                Text("Success!")
//                    .font(.largeTitle).fontWeight(.bold)
//                Text("Your capsule has been created")
//                    .font(.body).foregroundColor(.secondary)
//                Text("Your friends have been notified")
//                    .font(.caption).foregroundColor(.secondary)
//            }
//
//            Spacer()
//
//            // Action Buttons
//            VStack(spacing: 12) {
//                Button("View Capsule") {
//                    navigateToCapsule = true
//                }
//                .font(.headline)
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color.blue)
//                .cornerRadius(12)
//
//                Button("Back to Home") {
//                    navigateToHome = true
//                }
//                .font(.headline)
//                .foregroundColor(.blue)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color.blue.opacity(0.1))
//                .cornerRadius(12)
//            }
//            .padding(.horizontal, 30)
//            .padding(.bottom, 40)
//        }
//        .navigationTitle("Success")
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarBackButtonHidden(true)
//        .navigationDestination(isPresented: $navigateToCapsule) {
//            CapsuleDetailView(
//                viewModel: capsuleViewModel,
//                groupId: newGroupId
//            )
//        }
//        .navigationDestination(isPresented: $navigateToHome) {
//            HomePageView()
//        }
//    }
//}
