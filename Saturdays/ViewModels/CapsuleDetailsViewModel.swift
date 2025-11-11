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
    
    init(capsule: CapsuleModel) {
        self.capsule = capsule
    }
}
