//
//  LoginViewTests.swift
//  Saturdays
//

import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

@MainActor
struct LoginViewTests {

    @Test
    func testLoginFlowWithViewModel() async throws {
        let mockAuth = MockAuth()
        let mockDB = MockDB()

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
    func testLoginButtonExists() throws {
        let vm = AuthViewModel()
        let sut = LoginView().environmentObject(vm)

        _ = try sut.inspect().find(button: "Log In")
        #expect(true)   // If find does not throw, the button exists
    }
    
    @Test
    func testCreateAccountButtonExists() throws {
        let vm = AuthViewModel()
        let sut = LoginView().environmentObject(vm)

        _ = try sut.inspect().find(button: "Create Account")
        #expect(true)
    }
    
    @Test
    func testTextFieldsExist() throws {
        let vm = AuthViewModel()
        let sut = LoginView().environmentObject(vm)

        _ = try sut.inspect().find(ViewType.TextField.self)       // email field
        _ = try sut.inspect().find(ViewType.SecureField.self)     // password field
        #expect(true)
    }
    
    @Test
    func testErrorMessageAppearsWhenSet() throws {
        let vm = AuthViewModel()
        vm.errorMessage = "Test error"

        let sut = LoginView().environmentObject(vm)

        let errorText = try sut.inspect().find(text: "Test error")
        #expect(try errorText.string() == "Test error")
    }
}
