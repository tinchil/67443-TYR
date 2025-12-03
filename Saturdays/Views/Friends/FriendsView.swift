//
//  FriendsView.swift
//  Saturdays
//
//  Created by Yining He  on 12/3/25.
//

import SwiftUI
import Combine

struct FriendsView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = FriendsViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            
            // MARK: - CUSTOM NAV BAR
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                NavigationLink {
                    AddFriendView(vm: vm)
                } label: {
                    Image(systemName: "person.badge.plus")
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            // TITLE
            Text("Friends")
                .font(.largeTitle.bold())
                .padding(.horizontal)

            // MARK: - SEARCH BOX
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search Friend...", text: $vm.searchText)
                    .onChange(of: vm.searchText) { _ in vm.search() }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(18)
            .padding(.horizontal)

            ScrollView(showsIndicators: false) {

                // MARK: - REQUESTS SECTION
                if !vm.requests.isEmpty {
                    Text("Requests")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(vm.requests) { req in
                        RequestCell(request: req,
                                    acceptAction: { vm.accept(request: req) },
                                    deleteAction: { vm.delete(request: req) })
                    }
                    .padding(.horizontal)
                }

                // MARK: - FRIENDS LIST
                Text("Your Friends")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 10)

                ForEach(vm.friends) { friend in
                    FriendCell(friend: friend,
                               removeAction: { vm.remove(friend: friend) })
                        .padding(.horizontal)
                }

                Spacer(minLength: 100)
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color(red: 0.95, green: 0.96, blue: 1).ignoresSafeArea())
    }

}

// MARK: - Request Cell
struct RequestCell: View {
    let request: FriendRequest
    let acceptAction: () -> Void
    let deleteAction: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "person.circle")
                .font(.title)

            VStack(alignment: .leading) {
                Text(request.fromUsername)
                    .font(.headline)
                Text(request.fromDisplayName)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Button("Accept") { acceptAction() }
                .padding(8)
                .background(Color.blue.opacity(0.15))
                .cornerRadius(10)

            Button("Delete") { deleteAction() }
                .padding(8)
                .background(Color.red.opacity(0.15))
                .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
    }
}

// MARK: - Friend Cell
struct FriendCell: View {
    let friend: Friend
    let removeAction: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "person.circle")
                .font(.title)

            VStack(alignment: .leading) {
                Text(friend.username)
                Text(friend.displayName)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()

            Button(action: removeAction) {
                Image(systemName: "trash")
            }
            .padding(.trailing)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
    }
}
