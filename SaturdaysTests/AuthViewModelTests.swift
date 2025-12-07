//
//  AuthViewModelTests.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/6/25.
//


import Testing
import Foundation
@testable import Saturdays

@MainActor
struct AuthViewModelTests {
    
    @Test
    func testSignupSuccessUpdatesState() async throws {
        let mockAuth = MockAuth()
        let mockDB = MockDB()
        
        AuthService.shared.auth = mockAuth
        AuthService.shared.database = mockDB
        
        let vm = AuthViewModel()
        vm.username = "rose"
        vm.displayName = "Rosemary"
        vm.email = "a@b.com"
        vm.password = "1234"
        
        vm.createUser()
        
        // Wait for async completion
        try await Task.sleep(for: .milliseconds(100))
        
        #expect(vm.loggedInUser?.username == "rose")
        #expect(vm.loggedInUser?.displayName == "Rosemary")
        #expect(vm.loggedInUser?.email == "a@b.com")
        #expect(vm.errorMessage.isEmpty)
        #expect(vm.isLoading == false)
    }
    
    @Test
    func testSignupFailureShowsError() async throws {
        let mockAuth = MockAuth()
        mockAuth.shouldFail = true
        
        AuthService.shared.auth = mockAuth
        AuthService.shared.database = MockDB()
        
        let vm = AuthViewModel()
        vm.username = "rose"
        vm.displayName = "Rosemary"
        vm.email = "a@b.com"
        vm.password = "1234"
        
        vm.createUser()
        
        try await Task.sleep(for: .milliseconds(100))
        
        #expect(!vm.errorMessage.isEmpty)
        #expect(vm.loggedInUser == nil)
        #expect(vm.isLoading == false)
    }
    
    @Test
    func testLoginSuccessUpdatesState() async throws {
        let mockAuth = MockAuth()
        let mockDB = MockDB()
        
        // Pre-populate database
        mockDB.storedUsers["TEST_UID_1"] = UserModel(
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
        
        AuthService.shared.auth = mockAuth
        AuthService.shared.database = mockDB
        
        let vm = AuthViewModel()
        vm.email = "a@b.com"
        vm.password = "1234"
        
        vm.login()
        
        try await Task.sleep(for: .milliseconds(100))
        
        #expect(vm.loggedInUser?.email == "a@b.com")
        #expect(vm.loggedInUser?.username == "rose")
        #expect(vm.errorMessage.isEmpty)
        #expect(vm.isLoading == false)
    }
    
    @Test
    func testLoginFailureShowsError() async throws {
        let mockAuth = MockAuth()
        mockAuth.shouldFail = true
        
        AuthService.shared.auth = mockAuth
        AuthService.shared.database = MockDB()
        
        let vm = AuthViewModel()
        vm.email = "a@b.com"
        vm.password = "1234"
        
        vm.login()
        
        try await Task.sleep(for: .milliseconds(100))
        
        #expect(!vm.errorMessage.isEmpty)
        #expect(vm.loggedInUser == nil)
        #expect(vm.isLoading == false)
    }
    
    @Test
    func testLogout() async throws {
        let mockAuth = MockAuth()
        let mockDB = MockDB()
        
        AuthService.shared.auth = mockAuth
        AuthService.shared.database = mockDB
        
        let vm = AuthViewModel()
        
        // Set up logged in state
        vm.loggedInUser = UserModel(
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
        
        #expect(vm.loggedInUser != nil)
        
        vm.logout()
        
        #expect(vm.loggedInUser == nil)
    }
    
    @Test
    func testIsAuthenticatedProperty() async throws {
        let vm = AuthViewModel()
        
        #expect(vm.isAuthenticated == false)
        
        vm.loggedInUser = UserModel(
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
        
        #expect(vm.isAuthenticated == true)
    }
}
