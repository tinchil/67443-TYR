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

    // MARK: - Set Group
    func setGroup(groupID: String, memberIDs: [String]) {
        self.selectedGroupID = groupID
        self.selectedMemberIDs = memberIDs
        self.capsule.groupID = groupID
    }
}
