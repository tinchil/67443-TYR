//
//  CapsuleViewModel.swift
//  Saturdays
//
//  Created by Claude Code
//

import Foundation
import SwiftUI
import Combine

class CapsuleViewModel: ObservableObject {
    // Published array of groups (each containing a capsule)
    @Published var groups: [Group] = SampleData.sampleGroups

    // MARK: - Capsule Management Methods

    /// Updates a capsule's details
    func updateCapsule(groupId: UUID, name: String, description: String, type: CapsuleType, revealDate: Date, revealCycle: RevealCycle, lockPeriod: Date, contributionRequirement: ContributionRequirement) {
        guard let index = groups.firstIndex(where: { $0.id == groupId }) else { return }
        guard var capsule = groups[index].capsule else { return }

        // Update capsule properties
        capsule.name = name
        capsule.description = description
        capsule.type = type
        capsule.revealDate = revealDate
        capsule.revealCycle = revealCycle
        capsule.lockPeriod = lockPeriod
        capsule.contributionRequirement = contributionRequirement

        // Update the group's capsule
        groups[index].capsule = capsule
    }

    /// Gets a specific group by ID
    func getGroup(by id: UUID) -> Group? {
        return groups.first(where: { $0.id == id })
    }

    /// Adds a new group with capsule
    func addGroup(_ group: Group) {
        groups.append(group)
    }

    /// Deletes a group
    func deleteGroup(groupId: UUID) {
        groups.removeAll(where: { $0.id == groupId })
    }

    /// Checks if a capsule is locked
    func isCapsuleLocked(groupId: UUID) -> Bool {
        guard let group = getGroup(by: groupId),
              let capsule = group.capsule else { return true }
        return capsule.lockPeriod > Date()
    }

    /// Gets the count of photos in a capsule
    func photoCount(for groupId: UUID) -> Int {
        guard let group = getGroup(by: groupId),
              let capsule = group.capsule else { return 0 }
        return capsule.photos.count
    }
}

// MARK: - Video Generation
extension CapsuleViewModel {
    func generateVideoIfUnlocked(for groupId: UUID, completion: @escaping (URL?) -> Void) {
        guard let index = groups.firstIndex(where: { $0.id == groupId }),
              let capsule = groups[index].capsule else {
            completion(nil)
            return
        }

        // Only generate if unlocked and not already created
        guard capsule.lockPeriod <= Date(), capsule.videoURL == nil else {
            completion(capsule.videoURL)
            return
        }

        VideoCreator.createVideo(from: capsule.photos) { url in
            if let url = url {
                var updatedCapsule = capsule
                updatedCapsule.videoURL = url
                self.groups[index].capsule = updatedCapsule
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                    completion(url)
                }
            } else {
                completion(nil)
            }
        }
    }
}
