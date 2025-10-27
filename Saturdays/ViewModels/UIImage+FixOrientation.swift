//
//  UIImage+FixOrientation.swift
//  Saturdays
//
//  Created by Rosemary Yang on 10/26/25.
//

import UIKit

extension UIImage {
    /// Normalizes image orientation for correct SwiftUI rendering.
    func fixedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalized ?? self
    }
}
