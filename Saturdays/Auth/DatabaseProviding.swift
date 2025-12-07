//
//  DatabaseProviding.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/6/25.
//


import Foundation
import FirebaseFirestore

// MARK: - Database Provider Protocol
protocol DatabaseProviding {
    func setUserData(_ user: UserModel, uid: String, completion: @escaping (Error?) -> Void)
    func getUserData(uid: String, completion: @escaping (UserModel?, Error?) -> Void)
}

// MARK: - Firestore Adapter
class FirestoreDatabase: DatabaseProviding {
    private let db = Firestore.firestore()
    
    func setUserData(_ user: UserModel, uid: String, completion: @escaping (Error?) -> Void) {
        do {
            try db.collection("users").document(uid).setData(from: user)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func getUserData(uid: String, completion: @escaping (UserModel?, Error?) -> Void) {
        db.collection("users").document(uid).getDocument { doc, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let doc = doc, doc.exists,
                  let user = try? doc.data(as: UserModel.self) else {
                completion(nil, NSError(domain: "Database", code: -1))
                return
            }
            
            completion(user, nil)
        }
    }
}
