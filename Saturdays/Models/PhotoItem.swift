//
//  PhotoItem.swift
//  Saturdays
//
//  Created by Rosemary Yang on 9/29/25.
//

import UIKit
import CoreLocation

struct PhotoItem: Identifiable {
    let id = UUID()
    let image: UIImage
    let location: CLLocation?
    let timestamp: Date
}
