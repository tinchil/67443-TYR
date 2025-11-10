//
//  SampleData.swift
//  Saturdays
//
//  Created by Claude Code
//

import Foundation
import UIKit

struct SampleData {
    // Create some sample groups with capsules
    static let sampleGroups: [Group] = [
        Group(
            name: "Senior Yr",
            members: [
                Friend(name: "Jenny Kim", username: "@jennykim"),
                Friend(name: "Alex Chen", username: "@alexchen"),
                Friend(name: "Maria Garcia", username: "@mariagarcia")
            ],
            capsule: Capsule(
                name: "Senior Yr",
                description: "Our final year memories",
                type: .memories,
                revealDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date(),
                revealCycle: .monthly,
                lockPeriod: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
                contributionRequirement: .weekly,
                photos: [
                    PhotoItem(image: createPlaceholderImage(text: "Photo 1"), location: nil, timestamp: Date()),
                    PhotoItem(image: createPlaceholderImage(text: "Photo 2"), location: nil, timestamp: Date()),
                    PhotoItem(image: createPlaceholderImage(text: "Photo 3"), location: nil, timestamp: Date()),
                    PhotoItem(image: createPlaceholderImage(text: "Photo 4"), location: nil, timestamp: Date())
                ]
            )
        ),
        Group(
            name: "Worldwide Travelers",
            members: [
                Friend(name: "Taylor Swift", username: "@taylorswift"),
                Friend(name: "Jordan Lee", username: "@jordanlee"),
                Friend(name: "Sam Wilson", username: "@samwilson")
            ],
            capsule: Capsule(
                name: "Japan Trip",
                description: "Amazing Japan adventure 2025",
                type: .travel,
                revealDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date(),
                revealCycle: .yearly,
                lockPeriod: Calendar.current.date(byAdding: .month, value: 2, to: Date()) ?? Date(),
                contributionRequirement: .minimum,
                photos: [
                    PhotoItem(image: createPlaceholderImage(text: "Tokyo"), location: nil, timestamp: Date()),
                    PhotoItem(image: createPlaceholderImage(text: "Kyoto"), location: nil, timestamp: Date()),
                    PhotoItem(image: createPlaceholderImage(text: "Osaka"), location: nil, timestamp: Date())
                ]
            )
        )
    ]

    // Helper function to create placeholder images
    private static func createPlaceholderImage(text: String) -> UIImage {
        let size = CGSize(width: 300, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // Background
            UIColor.systemGray5.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .medium),
                .foregroundColor: UIColor.systemGray,
                .paragraphStyle: paragraphStyle
            ]

            let textSize = (text as NSString).size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )

            (text as NSString).draw(in: textRect, withAttributes: attributes)
        }
    }
}
