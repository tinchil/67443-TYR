//
//  SaturdaysApp.swift
//  Saturdays
//
//  Created by Rosemary Yang on 9/29/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// MARK: - Firebase App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// MARK: - App Entry Point
@main
struct SaturdaysApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var auth = AuthViewModel()   // <- keep this

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isAuthenticated {
                    MainTabView()            // <-- Show tabs when logged in
                        .environmentObject(auth)
                } else {
                    LoginView()              // <-- Show login when logged out
                        .environmentObject(auth)
                }
            }
        }
    }
}
