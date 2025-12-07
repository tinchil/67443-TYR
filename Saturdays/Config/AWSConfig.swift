//
//  AWSConfig.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/7/25.
//

import Foundation

enum AWSConfig {

    static let accessKeyID = "DEV_PLACEHOLDER_KEY"
    static let secretAccessKey = "DEV_PLACEHOLDER_SECRET"

    static let region = "us-east-1"
    static let bucketName = "placeholder-bucket"

    static func publicURL(for path: String) -> String {
        return "https://\(bucketName).s3.\(region).amazonaws.com/\(path)"
    }

    static func capsuleMediaPath(capsuleID: String, fileName: String) -> String {
        return "dev/capsules/\(capsuleID)/media/\(fileName)"
    }

    static func capsuleCoverPath(capsuleID: String) -> String {
        return "dev/capsules/\(capsuleID)/cover.jpg"
    }
}
