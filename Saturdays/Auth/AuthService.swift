//
//  AuthService.swift
//  Saturdays
//
//  Created by Yining He  on 12/3/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthService {

    static let shared = AuthService()
    private let db = Firestore.firestore()

    // MARK: - CREATE ACCOUNT
    func createAccount(username: String,
                       displayName: String,
                       email: String,
                       password: String,
                       completion: @escaping (Result<UserModel, Error>) -> Void) {

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user else {
                completion(.failure(NSError(domain: "Auth", code: -1)))
                return
            }

            // Build UserModel
            let model = UserModel(
                id: user.uid,
                username: username,
                displayName: displayName,
                email: email,
                createdAt: Date(),
                friendIDs: [],
                incomingRequests: [],
                outgoingRequests: [],
                groupIDs: []
            )

            // Save to Firestore
            do {
                try self.db.collection("users")
                    .document(user.uid)
                    .setData(from: model)

                completion(.success(model))

            } catch {
                completion(.failure(error))
            }
        }
    }


    // MARK: - LOGIN
    func login(email: String,
               password: String,
               completion: @escaping (Result<UserModel, Error>) -> Void) {

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let uid = result?.user.uid else {
                completion(.failure(NSError(domain: "Auth", code: -1)))
                return
            }

            self.db.collection("users").document(uid).getDocument { doc, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let doc = doc, doc.exists,
                      let user = try? doc.data(as: UserModel.self) else {
                    completion(.failure(NSError(domain: "Auth", code: -2)))
                    return
                }

                completion(.success(user))
            }
        }
    }


    // MARK: - LOGOUT
    func logout() {
        try? Auth.auth().signOut()
    }
}
