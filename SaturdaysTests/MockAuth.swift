//
//  MockAuth.swift
//  SaturdaysTests
//
//  Created by Rosemary Yang on 12/6/25.
//

import Foundation
@testable import Saturdays

// MARK: - Mock User
struct MockUser: UserProtocol {
    let uid: String
}

// MARK: - Mock Auth Result
struct MockAuthResult: AuthResultProtocol {
    let user: UserProtocol
}

// MARK: - Mock Auth Provider
class MockAuth: AuthProviding {
    
    var createdEmail: String?
    var createdPassword: String?
    var signedInEmail: String?
    var signedInPassword: String?
    
    var shouldFail = false
    var mockUID = "TEST_UID_1"
    
    func createUser(withEmail email: String,
                    password: String,
                    completion: @escaping (AuthResultProtocol?, Error?) -> Void) {
        createdEmail = email
        createdPassword = password
        
        if shouldFail {
            completion(nil, NSError(domain: "MockAuth", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Mock auth creation failed"
            ]))
        } else {
            let mockUser = MockUser(uid: mockUID)
            let mockResult = MockAuthResult(user: mockUser)
            completion(mockResult, nil)
        }
    }
    
    func signIn(withEmail email: String,
                password: String,
                completion: @escaping (AuthResultProtocol?, Error?) -> Void) {
        signedInEmail = email
        signedInPassword = password
        
        if shouldFail {
            completion(nil, NSError(domain: "MockAuth", code: -2, userInfo: [
                NSLocalizedDescriptionKey: "Mock auth sign in failed"
            ]))
        } else {
            let mockUser = MockUser(uid: mockUID)
            let mockResult = MockAuthResult(user: mockUser)
            completion(mockResult, nil)
        }
    }
    
    func signOut() throws {
        // No-op for mock
    }
}
