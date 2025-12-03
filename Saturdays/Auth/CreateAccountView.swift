//
//  CreateAccountView.swift
//  Saturdays
//
//  Created by Yining He  on 12/3/25.
//

import SwiftUI

struct CreateAccountView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        VStack(spacing: 30) {

            // HEADER
            Text("Create Account")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 60)

            Group {
                TextField("Username", text: $auth.username)
                    .padding()
                    .background(Color(white: 0.92))
                    .cornerRadius(14)

                TextField("Display Name", text: $auth.displayName)
                    .padding()
                    .background(Color(white: 0.92))
                    .cornerRadius(14)

                TextField("Email", text: $auth.email)
                    .padding()
                    .background(Color(white: 0.92))
                    .cornerRadius(14)

                SecureField("Password", text: $auth.password)
                    .padding()
                    .background(Color(white: 0.92))
                    .cornerRadius(14)
            }
            .padding(.horizontal, 30)

            // BUTTON
            Button {
                auth.createUser()
            } label: {
                Text("Create Account")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 30)

            // ERROR
            if !auth.errorMessage.isEmpty {
                Text(auth.errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.top, 5)
            }

            Spacer()
        }
        .navigationBarBackButtonHidden(false)
    }
}
