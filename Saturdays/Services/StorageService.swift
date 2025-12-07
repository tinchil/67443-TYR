//
//  StorageService.swift
//  Saturdays
//
//  Created by Tin 12/5/2025
//
//  Simple S3 upload using URLSession with AWS Signature V4
//

import Foundation
import FirebaseAuth
import UIKit
import CryptoKit

class StorageService {

    private var currentUserID: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    // MARK: - UPLOAD IMAGE
    func uploadImage(
        _ image: UIImage,
        path: String,
        completion: @escaping (String?) -> Void
    ) {
        // Compress image to JPEG
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to data")
            completion(nil)
            return
        }

        print("📤 Uploading image to S3: \(path)")

        // Build S3 URL
        let urlString = "https://\(AWSConfig.bucketName).s3.\(AWSConfig.region).amazonaws.com/\(path)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            completion(nil)
            return
        }

        // Create request with AWS Signature V4
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")

        // Generate AWS Signature V4 headers
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let amzDate = dateFormatter.string(from: now)
        let dateStamp = String(amzDate.prefix(8))

        request.setValue(amzDate, forHTTPHeaderField: "x-amz-date")

        // Calculate content hash
        let payloadHash = sha256Hash(data: imageData)
        request.setValue(payloadHash, forHTTPHeaderField: "x-amz-content-sha256")

        // Generate authorization header
        let authorization = generateAWSv4Signature(
            request: request,
            method: "PUT",
            path: "/\(path)",
            payloadHash: payloadHash,
            amzDate: amzDate,
            dateStamp: dateStamp
        )

        request.setValue(authorization, forHTTPHeaderField: "Authorization")

        print("🔐 x-amz-date: \(amzDate)")
        print("🔐 Authorization: \(authorization)")

        // Upload
        let task = URLSession.shared.uploadTask(with: request, from: imageData) { data, response, error in
            if let error = error {
                print("❌ Error uploading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let publicURL = AWSConfig.publicURL(for: path)
                    print("✅ Image uploaded successfully: \(publicURL)")
                    DispatchQueue.main.async {
                        completion(publicURL)
                    }
                } else {
                    print("❌ Upload failed with status code: \(httpResponse.statusCode)")
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("Response: \(responseBody)")
                    }
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }

        task.resume()
    }

    // MARK: - Generate AWS Signature V4
    private func generateAWSv4Signature(request: URLRequest, method: String, path: String, payloadHash: String, amzDate: String, dateStamp: String) -> String {
        let algorithm = "AWS4-HMAC-SHA256"
        let credentialScope = "\(dateStamp)/\(AWSConfig.region)/s3/aws4_request"

        // Build canonical headers based on method (must be sorted alphabetically)
        var canonicalHeaders: String
        var signedHeaders: String

        if method == "PUT" {
            canonicalHeaders = "content-type:image/jpeg\nhost:\(AWSConfig.bucketName).s3.\(AWSConfig.region).amazonaws.com\nx-amz-content-sha256:\(payloadHash)\nx-amz-date:\(amzDate)\n"
            signedHeaders = "content-type;host;x-amz-content-sha256;x-amz-date"
        } else {
            // DELETE only needs host and x-amz headers
            canonicalHeaders = "host:\(AWSConfig.bucketName).s3.\(AWSConfig.region).amazonaws.com\nx-amz-content-sha256:\(payloadHash)\nx-amz-date:\(amzDate)\n"
            signedHeaders = "host;x-amz-content-sha256;x-amz-date"
        }

        // Canonical request format: Method\nURI\nQueryString\nHeaders\n\nSignedHeaders\nPayloadHash
        let canonicalRequest = "\(method)\n\(path)\n\n\(canonicalHeaders)\n\(signedHeaders)\n\(payloadHash)"

        let canonicalRequestHash = sha256Hash(string: canonicalRequest)

        // String to sign
        let stringToSign = """
        \(algorithm)
        \(amzDate)
        \(credentialScope)
        \(canonicalRequestHash)
        """

        // Calculate signature
        let signingKey = getSignatureKey(key: AWSConfig.secretAccessKey, dateStamp: dateStamp, regionName: AWSConfig.region, serviceName: "s3")
        let signature = hmacSHA256(key: signingKey, data: Data(stringToSign.utf8)).map { String(format: "%02x", $0) }.joined()

        // Authorization header
        return "\(algorithm) Credential=\(AWSConfig.accessKeyID)/\(credentialScope), SignedHeaders=\(signedHeaders), Signature=\(signature)"
    }

    // MARK: - Crypto helpers
    private func sha256Hash(data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    private func sha256Hash(string: String) -> String {
        let data = Data(string.utf8)
        return sha256Hash(data: data)
    }

    private func hmacSHA256(key: Data, data: Data) -> Data {
        let symmetricKey = SymmetricKey(data: key)
        let signature = HMAC<SHA256>.authenticationCode(for: data, using: symmetricKey)
        return Data(signature)
    }

    private func getSignatureKey(key: String, dateStamp: String, regionName: String, serviceName: String) -> Data {
        let kDate = hmacSHA256(key: Data("AWS4\(key)".utf8), data: Data(dateStamp.utf8))
        let kRegion = hmacSHA256(key: kDate, data: Data(regionName.utf8))
        let kService = hmacSHA256(key: kRegion, data: Data(serviceName.utf8))
        let kSigning = hmacSHA256(key: kService, data: Data("aws4_request".utf8))
        return kSigning
    }

    // MARK: - UPLOAD MULTIPLE IMAGES
    func uploadImages(
        _ images: [UIImage],
        capsuleID: String,
        completion: @escaping ([String]) -> Void
    ) {
        var uploadedURLs: [String] = []
        let group = DispatchGroup()

        for (index, image) in images.enumerated() {
            group.enter()

            // Path: capsules/{capsuleID}/media/{timestamp}_{index}.jpg
            let timestamp = Int(Date().timeIntervalSince1970)
            let fileName = "\(timestamp)_\(index).jpg"
            let path = AWSConfig.capsuleMediaPath(capsuleID: capsuleID, fileName: fileName)

            uploadImage(image, path: path) { url in
                defer { group.leave() }

                if let url = url {
                    uploadedURLs.append(url)
                }
            }
        }

        group.notify(queue: .main) {
            print("📤 Uploaded \(uploadedURLs.count)/\(images.count) images")
            completion(uploadedURLs)
        }
    }

    // MARK: - UPLOAD COVER PHOTO
    func uploadCoverPhoto(
        _ image: UIImage,
        capsuleID: String,
        completion: @escaping (String?) -> Void
    ) {
        let path = AWSConfig.capsuleCoverPath(capsuleID: capsuleID)
        uploadImage(image, path: path, completion: completion)
    }

    // MARK: - DELETE IMAGE
    func deleteImage(url: String, completion: @escaping (Bool) -> Void) {
        // Extract key from URL
        guard let urlComponents = URLComponents(string: url) else {
            print("❌ Invalid URL format")
            completion(false)
            return
        }

        let key = String(urlComponents.path.dropFirst())

        // Build S3 URL
        let deleteURLString = "https://\(AWSConfig.bucketName).s3.\(AWSConfig.region).amazonaws.com/\(key)"
        guard let deleteURL = URL(string: deleteURLString) else {
            completion(false)
            return
        }

        var request = URLRequest(url: deleteURL)
        request.httpMethod = "DELETE"

        // Generate AWS Signature V4
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let amzDate = dateFormatter.string(from: now)
        let dateStamp = String(amzDate.prefix(8))

        request.setValue(amzDate, forHTTPHeaderField: "x-amz-date")

        let payloadHash = sha256Hash(data: Data())
        request.setValue(payloadHash, forHTTPHeaderField: "x-amz-content-sha256")

        let authorization = generateAWSv4Signature(
            request: request,
            method: "DELETE",
            path: "/\(key)",
            payloadHash: payloadHash,
            amzDate: amzDate,
            dateStamp: dateStamp
        )

        request.setValue(authorization, forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    print("✅ Image deleted successfully")
                    DispatchQueue.main.async {
                        completion(true)
                    }
                } else {
                    print("❌ Delete failed with status code: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }

        task.resume()
    }

    // MARK: - DELETE MULTIPLE IMAGES
    func deleteImages(urls: [String], completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var allSucceeded = true

        for url in urls {
            group.enter()
            deleteImage(url: url) { success in
                if !success {
                    allSucceeded = false
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(allSucceeded)
        }
    }
}
