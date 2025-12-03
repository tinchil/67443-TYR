//
//  LoginView.swift
//  Saturdays
//
//  Created by Yining He  on 12/3/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showCreateAccount = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                // MARK: - Title
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)

                // MARK: - Email
                TextField("Email", text: $email)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .frame(height: 50)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(12)

                // MARK: - Password
                SecureField("Password", text: $password)
                    .padding()
                    .frame(height: 50)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(12)

                // MARK: - Log In Button
                Button(action: {
                    auth.email = email
                    auth.password = password
                    auth.login()          // ← FIXED
                }) {
                    Text("Log In")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.black)
                        .cornerRadius(12)
                        .font(.headline)
                }
                .padding(.top, 8)

                // MARK: - Error Message
                if !auth.errorMessage.isEmpty {     // ← FIXED
                    Text(auth.errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                // MARK: - Create Account Navigation
                Button("Create Account") {
                    showCreateAccount = true
                }
                .font(.headline)
                .foregroundColor(Color.blue)

                NavigationLink("", destination: CreateAccountView(), isActive: $showCreateAccount)
            }
            .padding(.horizontal, 24)
        }
    }
}
