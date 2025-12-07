//
//  MockDB.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/6/25.
//


import Foundation
@testable import Saturdays

// MARK: - Mock Database Provider
class MockDB: DatabaseProviding {
    
    var storedUsers: [String: UserModel] = [:]
    var shouldFail = false
    
    func setUserData(_ user: UserModel, uid: String, completion: @escaping (Error?) -> Void) {
        if shouldFail {
            completion(NSError(domain: "MockDB", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Mock database write failed"
            ]))
        } else {
            storedUsers[uid] = user
            completion(nil)
        }
    }
    
    func getUserData(uid: String, completion: @escaping (UserModel?, Error?) -> Void) {
        if shouldFail {
            completion(nil, NSError(domain: "MockDB", code: -2, userInfo: [
                NSLocalizedDescriptionKey: "Mock database read failed"
            ]))
        } else if let user = storedUsers[uid] {
            completion(user, nil)
        } else {
            completion(nil, NSError(domain: "MockDB", code: -3, userInfo: [
                NSLocalizedDescriptionKey: "User not found"
            ]))
        }
    }
}