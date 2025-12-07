//
//  AWSConfig.swift
//  Saturdays
//
//  SAFE placeholder config for development.
//  DO NOT PUT REAL KEYS HERE.
//

import Foundation

enum AWSConfig {

    // Fake placeholder keys — SAFE to commit
    static let accessKeyID = "DEV_PLACEHOLDER_KEY"
    static let secretAccessKey = "DEV_PLACEHOLDER_SECRET"

    // Region and bucket can be real or dev versions
    static let region = "us-east-1"
    static let bucketName = "placeholder-bucket"

    // PUBLIC URL generator
    static func publicURL(for path: String) -> String {
        return "https://\(bucketName).s3.\(region).amazonaws.com/\(path)"
    }

    // File paths used by StorageService
    static func capsuleMediaPath(capsuleID: String, fileName: String) -> String {
        return "dev/capsules/\(capsuleID)/media/\(fileName)"
    }

    static func capsuleCoverPath(capsuleID: String) -> String {
        return "dev/capsules/\(capsuleID)/cover.jpg"
    }
}
