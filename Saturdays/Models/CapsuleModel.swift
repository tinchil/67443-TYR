//
//  CapsuleModel.swift
//  Saturdays
//
//  Created by Yining He  on 11/30/25.
//

import SwiftUI

struct CapsuleModel: Identifiable {
    let id = UUID()
    var name: String = ""
    var type: CapsuleType
    var groupID: String? = nil
    var coverPhoto: UIImage? = nil
}


