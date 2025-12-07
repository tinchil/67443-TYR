//
//  CapsuleDetailsViewModel.swift
//  Saturdays
//
//  Created by Yining He  on 11/30/25.
//

import SwiftUI
import Combine

class CapsuleDetailsViewModel: ObservableObject {
    @Published var capsule: CapsuleModel
    @Published var selectedGroupID: String?
    @Published var selectedMemberIDs: [String] = []

    init(capsule: CapsuleModel) {
        self.capsule = capsule
    }

    func setGroup(groupID: String, memberIDs: [String]) {
        self.selectedGroupID = groupID
        self.selectedMemberIDs = memberIDs
        self.capsule.groupID = groupID

        // defaults
        if capsule.revealDate == nil { capsule.revealDate = Date() }
        if capsule.minContribution == nil { capsule.minContribution = 0 }
    }

    // NEW
    func setReveal(date: Date?) {
        capsule.revealDate = date ?? Date()
    }

    func setMinContribution(_ count: Int?) {
        capsule.minContribution = count ?? 0
    }
}
