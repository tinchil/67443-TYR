//
//  AuthService.swift
//  Saturdays
//
//  Created by Yining He  on 12/3/25.
//

import Foundation
import FirebaseAuth

class AuthService {
    
    static let shared = AuthService()
    
    // Dependency injection for testing
    var auth: AuthProviding
    var database: DatabaseProviding
    
    init(auth: AuthProviding = FirebaseAuthProvider(),
         database: DatabaseProviding = FirestoreDatabase()) {
        self.auth = auth
        self.database = database
    }
    
    // MARK: - CREATE ACCOUNT
    func createAccount(username: String,
                       displayName: String,
                       email: String,
                       password: String,
                       completion: @escaping (Result<UserModel, Error>) -> Void) {
        
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let uid = result?.user.uid else {
                completion(.failure(NSError(domain: "Auth", code: -1)))
                return
            }
            
            // Build UserModel
            let model = UserModel(
                id: uid,
                username: username,
                displayName: displayName,
                email: email,
                createdAt: Date(),
                friendIDs: [],
                incomingRequests: [],
                outgoingRequests: [],
                groupIDs: []
            )
            
            // Save to database
            self.database.setUserData(model, uid: uid) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(model))
                }
            }
        }
    }
    
    // MARK: - LOGIN
    func login(email: String,
               password: String,
               completion: @escaping (Result<UserModel, Error>) -> Void) {
        
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let uid = result?.user.uid else {
                completion(.failure(NSError(domain: "Auth", code: -1)))
                return
            }
            
            self.database.getUserData(uid: uid) { user, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let user = user else {
                    completion(.failure(NSError(domain: "Auth", code: -2)))
                    return
                }
                
                completion(.success(user))
            }
        }
    }
    
    // MARK: - LOGOUT
    func logout() {
        try? auth.signOut()
    }
}
