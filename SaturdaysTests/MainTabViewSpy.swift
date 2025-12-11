//
//  MainTabViewSpy.swift
//  SaturdaysTests
//

@testable import Saturdays   // ← REQUIRED

protocol MainTabViewSpy {
    func didSelect(tab: Tab)
    func didPressCreate()
}

final class MainTabSpyRecorder: MainTabViewSpy {
    private(set) var selectedTabs: [Tab] = []
    private(set) var createPressed = false

    func didSelect(tab: Tab) { selectedTabs.append(tab) }
    func didPressCreate() { createPressed = true }
}
