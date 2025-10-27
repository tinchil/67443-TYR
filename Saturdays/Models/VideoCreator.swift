import AVKit

class VideoCreator {
    static func createVideo(from photos: [PhotoItem], completion: @escaping (URL?) -> Void) {
        guard !photos.isEmpty else { completion(nil); return }

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("compilation_\(UUID().uuidString).mp4")
        try? FileManager.default.removeItem(at: outputURL)

        guard let writer = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else {
            completion(nil)
            return
        }

        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 1080,
            AVVideoHeightKey: 1920
        ]

        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: writerInput,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
                kCVPixelBufferWidthKey as String: 1080,
                kCVPixelBufferHeightKey as String: 1920
            ]
        )

        writer.add(writerInput)
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)

        let frameDuration = CMTime(seconds: 2.0, preferredTimescale: 600)
        var frameCount = 0

        let queue = DispatchQueue(label: "videoQueue")
        writerInput.requestMediaDataWhenReady(on: queue) {
            while writerInput.isReadyForMoreMediaData && frameCount < photos.count {
                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
                if let buffer = PixelBufferRenderer.createPixelBuffer(
                    from: photos[frameCount].image,
                    size: CGSize(width: 1080, height: 1920)
                ) {
                    adaptor.append(buffer, withPresentationTime: presentationTime)
                }
                frameCount += 1
            }

            if frameCount >= photos.count {
                writerInput.markAsFinished()
                writer.finishWriting {
                    DispatchQueue.main.async {
                        completion(writer.status == .completed ? outputURL : nil)
                    }
                }
            }
        }
    }
}
