import SwiftUI

struct MainTabView: View {
    @Binding var selectedTab: Tab
    @Binding var showCreateOverlay: Bool
    @StateObject private var homeVM = HomeViewModel()
    @State private var showCreateCapsule = false

    // NORMAL APP ENTRYPOINT
    init() {
        self._selectedTab = .constant(.home)
        self._showCreateOverlay = .constant(false)
    }

    // TEST ENTRYPOINT
    init(selectedTab: Binding<Tab>, showCreateOverlay: Binding<Bool>) {
        self._selectedTab = selectedTab
        self._showCreateOverlay = showCreateOverlay
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
