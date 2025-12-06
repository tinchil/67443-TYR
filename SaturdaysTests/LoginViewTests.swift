//
//  LoginViewTests.swift
//  Saturdays
//

import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

extension LoginView: Inspectable {}

@MainActor
struct LoginViewTests {

    @Test
    func testLoginFlowWithViewModel() async throws {
        // This tests the actual login logic without fighting ViewInspector
        let mockAuth = MockAuth()
        let mockDB = MockDB()

        // Use the same UID that MockAuth returns
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
        
        // Simulate what the button does - set email/password and call login
        vm.email = "a@b.com"
        vm.password = "1234"
        vm.login()

        // Wait for async operation
        try await Task.sleep(for: .milliseconds(150))

        #expect(mockAuth.signedInEmail == "a@b.com")
        #expect(mockAuth.signedInPassword == "1234")
        #expect(vm.loggedInUser?.email == "a@b.com")
        #expect(vm.loggedInUser?.username == "rose")
        #expect(vm.errorMessage.isEmpty)
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

        try await Task.sleep(for: .milliseconds(150))

        #expect(!vm.errorMessage.isEmpty)
        #expect(vm.errorMessage.contains("failed"))
        #expect(vm.loggedInUser == nil)
    }


    @Test
    func testLoginButtonExists() async throws {
        let vm = AuthViewModel()
        let sut = LoginView().environmentObject(vm)

        // Verify the login button exists
        let button = try sut.inspect().find(button: "Log In")
        #expect(button != nil)
    }
    
    @Test
    func testCreateAccountButtonExists() async throws {
        let vm = AuthViewModel()
        let sut = LoginView().environmentObject(vm)

        // Should find the "Create Account" button
        let button = try sut.inspect().find(button: "Create Account")
        #expect(button != nil)
    }
    
    @Test
    func testTextFieldsExist() async throws {
        let vm = AuthViewModel()
        let sut = LoginView().environmentObject(vm)
        
        // Verify email field exists
        let emailField = try sut.inspect().find(ViewType.TextField.self)
        #expect(emailField != nil)
        
        // Verify password field exists
        let passwordField = try sut.inspect().find(ViewType.SecureField.self)
        #expect(passwordField != nil)
    }
    
    @Test
    func testErrorMessageAppearsWhenSet() async throws {
        let vm = AuthViewModel()
        vm.errorMessage = "Test error"
        
        let sut = LoginView().environmentObject(vm)
        
        // Error text should appear in the UI
        let errorText = try sut.inspect().find(text: "Test error")
        #expect(errorText != nil)
    }
}
