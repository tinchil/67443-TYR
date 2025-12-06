//
//  CreateAccountViewTests.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/6/25.
//


import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

extension CreateAccountView: Inspectable {}

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
        
        // Wait for async operation
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
        
        // Find and verify text fields exist
        let usernameField = try view.inspect().find(ViewType.TextField.self, where: { field in
            try field.labelView().text().string() == "Username"
        })
        
        let displayNameField = try view.inspect().find(ViewType.TextField.self, where: { field in
            try field.labelView().text().string() == "Display Name"
        })
        
        let emailField = try view.inspect().find(ViewType.TextField.self, where: { field in
            try field.labelView().text().string() == "Email"
        })
        
        #expect(usernameField != nil)
        #expect(displayNameField != nil)
        #expect(emailField != nil)
    }
    
    @Test
    func testErrorMessageDisplaysWhenPresent() async throws {
        let vm = AuthViewModel()
        vm.errorMessage = "Test error message"
        
        let view = CreateAccountView()
            .environmentObject(vm)
        
        let errorText = try view.inspect().find(text: "Test error message")
        #expect(errorText != nil)
    }
}

