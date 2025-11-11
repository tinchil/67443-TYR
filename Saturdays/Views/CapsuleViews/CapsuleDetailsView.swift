//
//  CapsuleDetailsView.swift
//  Saturdays
//
//  Created by Claude Code
//

import SwiftUI

struct CapsuleDetailsView: View {
    @ObservedObject var viewModel: CapsuleDetailsViewModel
    
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
            
            Spacer()
        }
        .padding()
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
