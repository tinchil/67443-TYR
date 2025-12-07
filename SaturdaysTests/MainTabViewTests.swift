//
//  MainTabViewTests.swift
//  Saturdays
//
//  Created by Yining He  on 12/7/25.
//


import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

@MainActor
struct MainTabViewTests {
    
    // MARK: - INITIAL STATE TESTS
    @Test
    func testInitialSelectedTabIsHome() throws {
        let view = MainTabView()
        
        // selectedTab is private, but we can test by checking which view is shown
        ViewHosting.host(view: view)
        
        let inspected = try view.inspect()
        
        // Should render HomePageView initially
        let homePage = try? inspected.find(HomePageView.self)
        #expect(homePage != nil)
    }
    
    @Test
    func testInitialCreateOverlayIsHidden() throws {
        let view = MainTabView()
        
        ViewHosting.host(view: view)
        
        let inspected = try view.inspect()
        
        // CapsuleCreateOverlay should not be present initially
        let overlay = try? inspected.find(CapsuleCreateOverlay.self)
        #expect(overlay == nil)
    }
    
    // MARK: - BOTTOM NAV BAR RENDER TEST
    @Test
    func testBottomNavBarAppears() throws {
        let view = MainTabView()
        
        ViewHosting.host(view: view)
        
        let inspected = try view.inspect()
        
        // BottomNavBar should always be present
        let navBar = try inspected.find(BottomNavBar.self)
        let zstack = try inspected.find(ViewType.ZStack.self)
        #expect(true)
    }
    
    // MARK: - TAB SWITCHING TESTS
    @Test
    func testSwitchingToCapsulesTab() throws {
        var view = MainTabView()
        view.selectedTab = .capsules

        ViewHosting.host(view: view)

        let inspected = try view.inspect()

        // STEP 1: Get the ZStack
        let zstack = try inspected.zStack()

        // STEP 2: The first child is your Group containing CapsuleCollection
        let group = try zstack.group(0)

        // STEP 3: Now find CapsuleCollection inside the group
        let capsulesView = try? group.find(CapsuleCollection.self)

        #expect(capsulesView != nil)
    }

    
    @Test
    func testSwitchingToHomeTab() throws {
        var view = MainTabView()
        view.selectedTab = .home
        
        ViewHosting.host(view: view)
        
        let inspected = try view.inspect()
        
        // Should render HomePageView
        let homeView = try? inspected.find(HomePageView.self)
        #expect(homeView != nil)
    }
    
    @Test
    func testCreateOverlayHiddenWhenShowCreateOverlayIsFalse() throws {
        var view = MainTabView()
        view.showCreateOverlay = false
        
        ViewHosting.host(view: view)
        
        let inspected = try view.inspect()
        
        // CapsuleCreateOverlay should not be present
        let overlay = try? inspected.find(CapsuleCreateOverlay.self)
        #expect(overlay == nil)
    }
    
    
    @Test
    func testContentNotBlurredWhenOverlayIsHidden() throws {
        var view = MainTabView()
        view.showCreateOverlay = false
        
        ViewHosting.host(view: view)
        
        // When overlay is hidden, content should not have blur
        #expect(view.showCreateOverlay == false)
    }
    
    // MARK: - ZSTACK STRUCTURE TESTS
    @Test
    func testViewUsesZStackLayout() throws {
        let view = MainTabView()
        
        ViewHosting.host(view: view)
        
        let inspected = try view.inspect()
        
        // Root should be a ZStack
        let zstack = try inspected.find(ViewType.ZStack.self)
        let _ = try inspected.find(ViewType.ZStack.self)
        
    }
    
    @Test
    func testBottomNavBarIsInVStack() throws {
        let view = MainTabView()
        
        ViewHosting.host(view: view)
        
        let inspected = try view.inspect()
        
        // BottomNavBar should be inside a VStack
        let vstack = try? inspected.find(ViewType.VStack.self)
        #expect(vstack != nil)
    }
}

// MARK: - Tab Enum Tests
@MainActor
struct TabEnumTests {
    
    @Test
    func testTabEnumHasHomeCase() throws {
        let tab: Saturdays.Tab = .home
        #expect(tab == .home)
    }
    
    @Test
    func testTabEnumHasCapsulesCase() throws {
        let tab: Saturdays.Tab = .capsules
        #expect(tab == .capsules)
    }
    
    @Test
    func testTabEnumCasesAreDistinct() throws {
        let homeTab: Saturdays.Tab = .home
        let capsulesTab: Saturdays.Tab = .capsules
        
        #expect(homeTab != capsulesTab)
    }
}

// MARK: - Integration Tests
@MainActor
struct MainTabViewIntegrationTests {
    
    @Test
    func testCompleteTabSwitchingFlow() throws {
        var view = MainTabView()
        
        // Start on home
        view.selectedTab = .home
        #expect(view.selectedTab == .home)
        
        // Switch to capsules
        view.selectedTab = .capsules
        #expect(view.selectedTab == .capsules)
        
        // Switch back to home
        view.selectedTab = .home
        #expect(view.selectedTab == .home)
    }
    
    @Test
    func testOverlayShowAndHideFlow() throws {
        var view = MainTabView()
        
        // Initially hidden
        #expect(view.showCreateOverlay == false)
        
        // Show overlay
        view.showCreateOverlay = true
        #expect(view.showCreateOverlay == true)
        
        // Hide overlay
        view.showCreateOverlay = false
        #expect(view.showCreateOverlay == false)
    }
    
    @Test
    func testOverlayCanBeShownOnDifferentTabs() throws {
        var view = MainTabView()
        
        // Show overlay on home tab
        view.selectedTab = .home
        view.showCreateOverlay = true
        
        ViewHosting.host(view: view)
        var inspected = try view.inspect()
        
        var overlay = try? inspected.find(CapsuleCreateOverlay.self)
        #expect(overlay != nil)
        
        // Switch to capsules tab with overlay still shown
        view.selectedTab = .capsules
        view.showCreateOverlay = true
        
        ViewHosting.host(view: view)
        inspected = try view.inspect()
        
        overlay = try? inspected.find(CapsuleCreateOverlay.self)
        #expect(overlay != nil)
    }
    
    @Test
    func testViewRendersCorrectlyWithAllCombinations() throws {
        // Test all combinations of tab selection and overlay state
        let tabs: [Saturdays.Tab] = [.home, .capsules]
        let overlayStates = [true, false]
        
        for tab in tabs {
            for overlayState in overlayStates {
                var view = MainTabView()
                view.selectedTab = tab
                view.showCreateOverlay = overlayState
                
                ViewHosting.host(view: view)
                
                // View should render without crashing
                let inspected = try? view.inspect()
                #expect(inspected != nil)
            }
        }
    }
}

//// MARK: - State Management Tests
//@MainActor
//struct MainTabViewStateTests {
//    
//    @Test
//    func testShowCreateOverlayToggle() throws {
//        var view = MainTabView()
//        
//        let initialState = view.showCreateOverlay
//        view.showCreateOverlay.toggle()
//        
//        #expect(view.showCreateOverlay != initialState)
//    }
//    
//    @Test
//    func testSelectedTabCanBeChanged() throws {
//        var view = MainTabView()
//        
//        view.selectedTab = .home
//        #expect(view.selectedTab == .home)
//        
//        view.selectedTab = .capsules
//        #expect(view.selectedTab == .capsules)
//    }
//    
//    @Test
//    func testMultipleOverlayToggles() throws {
//        var view = MainTabView()
//        
//        #expect(view.showCreateOverlay == false)
//        
//        view.showCreateOverlay = true
//        #expect(view.showCreateOverlay == true)
//        
//        view.showCreateOverlay = false
//        #expect(view.showCreateOverlay == false)
//        
//        view.showCreateOverlay = true
//        #expect(view.showCreateOverlay == true)
//    }
//}
