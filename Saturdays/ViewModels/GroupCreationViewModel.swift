//
//  GroupCreationViewModel.swift
//  Saturdays
//
//  Created by Claude Code
//

import Foundation
import SwiftUI
import PhotosUI
import Combine

class GroupCreationViewModel: ObservableObject {
    // Friend Selection
    @Published var selectedFriends: [Friend] = []

    // Group Details
    @Published var groupName: String = ""
    @Published var groupDescription: String = ""

    // Capsule Details
    @Published var capsuleName: String = ""
    @Published var capsuleDescription: String = ""
    @Published var selectedType: CapsuleType = .memories
    @Published var revealDate: Date = Date()
    @Published var revealCycle: RevealCycle = .weekly
    @Published var lockPeriod: Date = Date()

    // Contribution Requirements
    @Published var contributionRequirement: ContributionRequirement = .none

    // Photos
    @Published var selectedPhotos: [UIImage] = []

    // Navigation state
    @Published var currentStep: CreationStep = .home

    enum CreationStep {
        case home
        case selectFriends
        case groupDetails
        case capsuleDetails
        case contributionRequirements
        case addPhotos
        case confirmPhotos
        case success
    }

    // Reset everything
    func reset() {
        selectedFriends.removeAll()
        groupName = ""
        groupDescription = ""
        capsuleName = ""
        capsuleDescription = ""
        selectedType = .memories
        revealDate = Date()
        revealCycle = .weekly
        lockPeriod = Date()
        contributionRequirement = .none
        selectedPhotos.removeAll()
        currentStep = .home
    }

    // Create the final group and capsule
    func createGroup() -> Group {
        let capsule = Capsule(
            name: capsuleName,
            description: capsuleDescription,
            type: selectedType,
            revealDate: revealDate,
            revealCycle: revealCycle,
            lockPeriod: lockPeriod,
            contributionRequirement: contributionRequirement,
            photos: selectedPhotos.map { photo in
                PhotoItem(
                    image: photo,
                    location: nil,
                    timestamp: Date()
                )
            }
        )

        return Group(
            name: groupName,
            members: selectedFriends,
            capsule: capsule
        )
    }

    // Validation helpers
    var canProceedFromFriendSelection: Bool {
        !selectedFriends.isEmpty
    }

    var canProceedFromGroupDetails: Bool {
        !groupName.isEmpty
    }

    var canProceedFromCapsuleDetails: Bool {
        !capsuleName.isEmpty
    }
}
