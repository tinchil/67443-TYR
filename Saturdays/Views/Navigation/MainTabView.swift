import SwiftUI

struct MainTabView: View {
    // The REAL source of truth
    @State private var selectedTab: Tab
    @State private var showCreateOverlay: Bool
    
    @StateObject private var homeVM = HomeViewModel()
    @State private var showCreateCapsule = false

    // MARK: - Production initializer (default values)
    init() {
        self._selectedTab = State(initialValue: .home)
        self._showCreateOverlay = State(initialValue: false)
    }

    // MARK: - Test initializer (injects initial state)
    init(selectedTab: Tab, showCreateOverlay: Bool) {
        self._selectedTab = State(initialValue: selectedTab)
        self._showCreateOverlay = State(initialValue: showCreateOverlay)
    }

    var body: some View {
        NavigationStack {
            ZStack {

                // MAIN CONTENT
                Group {
                    switch selectedTab {
                    case .home:
                        HomePageView()
                    case .capsules:
                        CapsuleCollection()
                    }
                }
                .blur(radius: showCreateOverlay ? 6 : 0)

                // BOTTOM NAV BAR
                VStack {
                    Spacer()
                    BottomNavBar(selectedTab: $selectedTab) {
                        withAnimation { showCreateOverlay = true }
                    }
                    .padding(.bottom, 20)
                }

                // CREATE OVERLAY
                if showCreateOverlay {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { showCreateOverlay = false }
                        }

                    CapsuleCreateOverlay(
                        dismiss: {
                            withAnimation { showCreateOverlay = false }
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
                }
            }
            .navigationDestination(isPresented: $showCreateCapsule) {
                CapsuleDetailsView(viewModel: homeVM.currentCapsuleVM)
            }
        }
    }
}
