import Foundation
import UIKit
import Vision

final class FaceEmbeddingService {

    static let shared = FaceEmbeddingService()
    private init() {}

    func embedding(for image: UIImage) async -> [Float]? {

        guard let cg = image.cgImage else { return nil }

        return await withCheckedContinuation { continuation in
            let request = VNGenerateImageFeaturePrintRequest { req, err in
                if let obs = req.results?.first as? VNFeaturePrintObservation {
                    continuation.resume(returning: Self.extractFloats(from: obs))
                } else {
                    continuation.resume(returning: nil)
                }
            }

            let handler = VNImageRequestHandler(cgImage: cg)
            DispatchQueue.global().async {
                try? handler.perform([request])
            }
        }
    }

    private static func extractFloats(from obs: VNFeaturePrintObservation) -> [Float]? {
        let data = obs.data
        let count = data.count / MemoryLayout<Float>.size
        guard count > 0 else { return nil }

        return data.withUnsafeBytes { buffer in
            Array(buffer.bindMemory(to: Float.self))
        }
    }
}
