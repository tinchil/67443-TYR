//
//  AuthServiceTests.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/6/25.
//


import Testing
import Foundation
@testable import Saturdays

struct AuthServiceTests {
    
    @Test
    func testCreateAccountSuccess() async throws {
        let mockAuth = MockAuth()
        let mockDB = MockDB()
        
        let service = AuthService(auth: mockAuth, database: mockDB)
        
        let result = await withCheckedContinuation { continuation in
            service.createAccount(
                username: "rose",
                displayName: "Rosemary",
                email: "a@b.com",
                password: "1234"
            ) { result in
                continuation.resume(returning: result)
            }
        }
        
        switch result {
        case .success(let user):
            #expect(user.username == "rose")
            #expect(user.displayName == "Rosemary")
            #expect(user.email == "a@b.com")
            #expect(mockAuth.createdEmail == "a@b.com")
            #expect(mockAuth.createdPassword == "1234")
            #expect(mockDB.storedUsers["TEST_UID_1"] != nil)
        case .failure:
            Issue.record("Expected success but got failure")
        }
    }
    
    @Test
    func testCreateAccountFailure() async throws {
        let mockAuth = MockAuth()
        mockAuth.shouldFail = true
        
        let service = AuthService(auth: mockAuth, database: MockDB())
        
        let result = await withCheckedContinuation { continuation in
            service.createAccount(
                username: "rose",
                displayName: "Rosemary",
                email: "a@b.com",
                password: "1234"
            ) { result in
                continuation.resume(returning: result)
            }
        }
        
        switch result {
        case .success:
            Issue.record("Expected failure but got success")
        case .failure(let error):
            #expect(error.localizedDescription.contains("failed"))
        }
    }
    
    @Test
    func testLoginSuccess() async throws {
        let mockAuth = MockAuth()
        let mockDB = MockDB()
        
        // Pre-populate the mock database
        let expectedUser = UserModel(
            id: "TEST_UID_1",
            username: "rose",
            displayName: "Rosemary",
            email: "a@b.com",
            createdAt: Date(),
            friendIDs: [],
            incomingRequests: [],
            outgoingRequests: [],
            groupIDs: []
        )
        mockDB.storedUsers["TEST_UID_1"] = expectedUser
        
        let service = AuthService(auth: mockAuth, database: mockDB)
        
        let result = await withCheckedContinuation { continuation in
            service.login(email: "a@b.com", password: "1234") { result in
                continuation.resume(returning: result)
            }
        }
        
        switch result {
        case .success(let user):
            #expect(user.username == "rose")
            #expect(user.email == "a@b.com")
            #expect(mockAuth.signedInEmail == "a@b.com")
            #expect(mockAuth.signedInPassword == "1234")
        case .failure:
            Issue.record("Expected success but got failure")
        }
    }
    
    @Test
    func testLoginFailure() async throws {
        let mockAuth = MockAuth()
        mockAuth.shouldFail = true
        
        let service = AuthService(auth: mockAuth, database: MockDB())
        
        let result = await withCheckedContinuation { continuation in
            service.login(email: "a@b.com", password: "1234") { result in
                continuation.resume(returning: result)
            }
        }
        
        switch result {
        case .success:
            Issue.record("Expected failure but got success")
        case .failure(let error):
            #expect(error.localizedDescription.contains("failed"))
        }
    }
    
    @Test
    func testLoginUserNotFound() async throws {
        let mockAuth = MockAuth()
        let mockDB = MockDB()
        // Don't add user to mockDB
        
        let service = AuthService(auth: mockAuth, database: mockDB)
        
        let result = await withCheckedContinuation { continuation in
            service.login(email: "a@b.com", password: "1234") { result in
                continuation.resume(returning: result)
            }
        }
        
        switch result {
        case .success:
            Issue.record("Expected failure but got success")
        case .failure(let error):
            #expect(error.localizedDescription.contains("not found"))
        }
    }
}
