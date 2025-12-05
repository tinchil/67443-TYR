//
//  AddFriendView.swift
//  Saturdays
//
//  Created by Yining He  on 12/3/25.
//

import SwiftUI

struct AddFriendView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: FriendsViewModel
    
    @State private var isSending = false
    @State private var feedbackMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // MARK: - CUSTOM NAV BAR
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            Text("Add Friend")
                .font(.largeTitle.bold())
                .padding(.horizontal)
            
            
            // MARK: - SEARCH FIELD
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Username / Account Number", text: $vm.searchText)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onChange(of: vm.searchText) { _ in vm.search() }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal)
            .padding(.top, 10)
            
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - SEARCH RESULT
                    if let user = vm.searchResult {
                        SearchResultCell(
                            user: user,
                            isSending: isSending,
                            isRequestSent: vm.hasPendingRequest(to: user),
                            sendRequestAction: sendRequest(to:)
                        )
                    } else if vm.searchText.count > 1 {
                        Text("No users found.")
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                    }
                    
                    if let message = feedbackMessage {
                        Text(message)
                            .foregroundColor(.blue)
                            .font(.subheadline)
                            .padding(.top, 5)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color(red: 0.95, green: 0.96, blue: 1).ignoresSafeArea())
    }
    
    
    // MARK: - SEND REQUEST LOGIC
    private func sendRequest(to user: UserModel) {
        guard !vm.hasPendingRequest(to: user) else { return }
        
        isSending = true
        feedbackMessage = nil
        
        vm.sendRequest(to: user)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isSending = false
            feedbackMessage = "Friend added!"
        }
    }
}


// MARK: - Search Result Cell
struct SearchResultCell: View {
    
    let user: UserModel
    let isSending: Bool
    let isRequestSent: Bool
    let sendRequestAction: (UserModel) -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            
            Image(systemName: "person.circle")
                .font(.system(size: 40))
                .foregroundColor(.black.opacity(0.8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.username)
                    .font(.headline)
                
                Text(user.displayName)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isRequestSent {
                Text("Friends")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(10)
                
            } else {
                Button(action: { sendRequestAction(user) }) {
                    if isSending {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(8)
                    } else {
                        Text("Add")
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                }
                .background(Color.blue.opacity(0.15))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}
