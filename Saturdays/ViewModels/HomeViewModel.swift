//
//  HomeViewModel.swift
//  Saturdays
//
//  Created by Yining He  on 11/30/25.
//

import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var promptOfTheDay: String = "What’s something you’re grateful for today?"
    
    @Published var capsules: [CapsuleModel] = []
    
    @Published var currentCapsuleVM = CapsuleDetailsViewModel(
        capsule: CapsuleModel(type: .memory)
    )
    
    func startCapsule(type: CapsuleType) {
        currentCapsuleVM = CapsuleDetailsViewModel(
            capsule: CapsuleModel(type: type)
        )
    }
}
