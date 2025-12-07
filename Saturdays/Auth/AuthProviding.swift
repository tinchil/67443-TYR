//
//  AuthProviding.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/6/25.
//

import Foundation
import FirebaseAuth

// MARK: - User Wrapper Protocol
protocol UserProtocol {
    var uid: String { get }
}

// MARK: - Auth Result Wrapper Protocol
protocol AuthResultProtocol {
    var user: UserProtocol { get }
}

// MARK: - Auth Provider Protocol
protocol AuthProviding {
    func createUser(withEmail: String,
                    password: String,
                    completion: @escaping (AuthResultProtocol?, Error?) -> Void)
    
    func signIn(withEmail: String,
                password: String,
                completion: @escaping (AuthResultProtocol?, Error?) -> Void)
    
    func signOut() throws
}

// MARK: - Firebase User Wrapper
extension FirebaseAuth.User: UserProtocol {
    // uid is already implemented by Firebase.User
}

// MARK: - Firebase Auth Result Wrapper
struct FirebaseAuthResultWrapper: AuthResultProtocol {
    let authDataResult: AuthDataResult
    
    var user: UserProtocol {
        return authDataResult.user
    }
}

// MARK: - Firebase Auth Provider
class FirebaseAuthProvider: AuthProviding {
    private let auth = Auth.auth()
    
    func createUser(withEmail email: String,
                    password: String,
                    completion: @escaping (AuthResultProtocol?, Error?) -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(nil, error)
            } else if let result = result {
                completion(FirebaseAuthResultWrapper(authDataResult: result), nil)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    func signIn(withEmail email: String,
                password: String,
                completion: @escaping (AuthResultProtocol?, Error?) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(nil, error)
            } else if let result = result {
                completion(FirebaseAuthResultWrapper(authDataResult: result), nil)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    func signOut() throws {
        try auth.signOut()
    }
}
