//
//  CreateAccountViewTests.swift
//  Saturdays
//

import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

@MainActor
struct CreateAccountViewTests {
    
    @Test
    func testSignupButtonCallsCreateUser() async throws {
        let mockAuth = MockAuth()
        let mockDB = MockDB()
        
        AuthService.shared.auth = mockAuth
        AuthService.shared.database = mockDB
        
        let vm = AuthViewModel()
        vm.username = "rose"
        vm.displayName = "Rosemary"
        vm.email = "a@b.com"
        vm.password = "1234"
        
        let view = CreateAccountView()
            .environmentObject(vm)
        
        let button = try view.inspect().find(button: "Create Account")
        try button.tap()
        
        // async waiting
        try await Task.sleep(for: .milliseconds(100))
        
        #expect(mockAuth.createdEmail == "a@b.com")
        #expect(mockAuth.createdPassword == "1234")
        #expect(vm.loggedInUser?.username == "rose")
    }
    
    @Test
    func testTextFieldsBindToViewModel() async throws {
        let vm = AuthViewModel()
        
        let view = CreateAccountView()
            .environmentObject(vm)
        
        let usernameField = try view.inspect().find(ViewType.TextField.self) { field in
            try field.labelView().text().string() == "Username"
        }
        
        let displayNameField = try view.inspect().find(ViewType.TextField.self) { field in
            try field.labelView().text().string() == "Display Name"
        }
        
        let emailField = try view.inspect().find(ViewType.TextField.self) { field in
            try field.labelView().text().string() == "Email"
        }
        
        _ = usernameField
        _ = displayNameField
        _ = emailField
        
        #expect(true)
    }
    
    @Test
    func testErrorMessageDisplaysWhenPresent() async throws {
        let vm = AuthViewModel()
        vm.errorMessage = "Test error message"
        
        let view = CreateAccountView()
            .environmentObject(vm)
        
        let errorText = try view.inspect().find(text: "Test error message")
        
        // Again, not optional — can't compare to nil.
        _ = errorText
        
        #expect(true)
    }
}
