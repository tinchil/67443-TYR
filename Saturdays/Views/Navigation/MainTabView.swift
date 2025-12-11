//
//  MainTabView.swift
//  Saturdays
//
//  Created by Yining He  on 12/1/25.
//
//
//import SwiftUI
//
//struct MainTabView: View {
//    @State private var selectedTab: Tab = .home
//    @State private var showCreateOverlay = false   // <---- CHANGED
//    
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            
//            // MAIN CONTENT SCREEN
//            Group {
//                switch selectedTab {
//                case .home:
//                    HomePageView()
//                case .create:
//                    EmptyView()
//                case .capsules:
//                    CapsuleCollection()
//                }
//            }
//            .blur(radius: showCreateOverlay ? 6 : 0)   // Optional blurred background
//            
//            
//            // BOTTOM NAV BAR
//            BottomNavBar(selectedTab: $selectedTab) {
//                withAnimation(.spring()) {
//                    showCreateOverlay = true
//                }
//            }
//            
//            
//            // CREATE NEW OVERLAY
//            if showCreateOverlay {
//                Color.black.opacity(0.35)
//                    .ignoresSafeArea()
//                    .onTapGesture {
//                        withAnimation(.easeOut) {
//                            showCreateOverlay = false
//                        }
//                    }
//                
//                CapsuleCreateOverlay {
//                    withAnimation(.easeOut) {
//                        showCreateOverlay = false
//                    }
//                }
//                .transition(.move(edge: .bottom).combined(with: .opacity))
//            }
//        }
//    }
//}
//

import SwiftUI

struct MainTabView: View {
    @State public var selectedTab: Tab = .home
    @State public var showCreateOverlay = false
    @StateObject private var homeVM = HomeViewModel()
    @State private var showCreateCapsule = false

    var body: some View {
        NavigationStack {
            ZStack {
            
            // MAIN CONTENT (stays visible)
            Group {
                switch selectedTab {
                case .home:
                    HomePageView()
                case .capsules:
                    CapsuleCollection()
                }
            }
            .blur(radius: showCreateOverlay ? 6 : 0)
            .animation(.easeOut, value: showCreateOverlay)
            
            // BOTTOM NAV BAR (ALWAYS FIXED)
            VStack {
                Spacer()
                BottomNavBar(selectedTab: $selectedTab) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showCreateOverlay = true
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            }
            .ignoresSafeArea(edges: .bottom)
            
            // POPUP OVERLAY
            if showCreateOverlay {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showCreateOverlay = false
                        }
                    }
                
                CapsuleCreateOverlay(
                    dismiss: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showCreateOverlay = false
                        }
                    },
                    onMemoryTap: {
                        homeVM.startCapsule(type: .memory)
                        showCreateCapsule = true
                    },
                    onLetterTap: {
                        homeVM.startCapsule(type: .letter)
                        showCreateCapsule = true
                    }
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
        .navigationDestination(isPresented: $showCreateCapsule) {
            CapsuleDetailsView(viewModel: homeVM.currentCapsuleVM)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissCapsuleFlow"))) { _ in
            showCreateCapsule = false
        }
        }
    }
}
