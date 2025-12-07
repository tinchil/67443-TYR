//
//  AWSConfig.swift
//  Saturdays
//
//  Created by Tin 12/5/2025
//

import Foundation

struct AWSConfig {

    // MARK: - AWS Credentials
    // TODO: Replace with your actual IAM credentials from AWS Console
    static let accessKeyID = "YOUR_AWS_ACCESS_KEY_HERE"  // Replace this!
    static let secretAccessKey = "YOUR_AWS_SECRET_ACCESS_KEY_HERE"  // Replace this!

    // MARK: - S3 Configuration
    static let bucketName = "saturdays-s3-capsules-media"
    static let region = "us-east-2"  // US East (Ohio)

    // MARK: - S3 Paths
    static func capsuleMediaPath(capsuleID: String, fileName: String) -> String {
        return "capsules/\(capsuleID)/media/\(fileName)"
    }

    static func capsuleCoverPath(capsuleID: String) -> String {
        return "capsules/\(capsuleID)/cover.jpg"
    }
    
    static func capsuleFinalVideoPath(capsuleID: String) -> String {
        return "capsules/\(capsuleID)/final_video.mp4"
    }

    // MARK: - Public URL Generator
    static func publicURL(for key: String) -> String {
        return "https://\(bucketName).s3.\(region).amazonaws.com/\(key)"
    }
}


