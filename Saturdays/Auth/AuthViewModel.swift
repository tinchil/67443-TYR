//
//  AuthViewModel.swift
//  Saturdays
//
//  Created by Yining He  on 12/3/25.
//

import Foundation
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {

    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var displayName = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var loggedInUser: UserModel?

    // MARK: - Compatibility for older code
    var currentUser: UserModel? { loggedInUser }
    var isAuthenticated: Bool { loggedInUser != nil }

    // MARK: - CREATE ACCOUNT
    func createUser() {
        errorMessage = ""
        isLoading = true

        AuthService.shared.createAccount(
            username: username,
            displayName: displayName,
            email: email,
            password: password
        ) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let user):
                    self.loggedInUser = user
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - LOGIN
    func login() {
        errorMessage = ""
        isLoading = true
        AuthService.shared.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let user):
                    self.loggedInUser = user
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - LOGOUT
    func logout() {
        try? Auth.auth().signOut()
        loggedInUser = nil
    }
}
