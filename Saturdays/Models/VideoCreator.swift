//
//  VideoCreator.swift
//  Saturdays
//
//  Created by Rosemary Yang on 9/29/25.
//

import AVKit

class VideoCreator {
    static func createVideo(from photos: [PhotoItem], completion: @escaping (URL?) -> Void) {
        guard !photos.isEmpty else {
            completion(nil)
            return
        }
        
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("compilation_\(UUID().uuidString).mp4")
        
        // Remove existing file if present
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
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        writerInput.requestMediaDataWhenReady(on: DispatchQueue(label: "videoQueue")) {
            while writerInput.isReadyForMoreMediaData && frameCount < photos.count {
                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
                
                if let pixelBuffer = self.pixelBuffer(from: photos[frameCount].image, size: CGSize(width: 1080, height: 1920)) {
                    adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                }
                
                frameCount += 1
            }
            
            if frameCount >= photos.count {
                writerInput.markAsFinished()
                writer.finishWriting {
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if writer.status == .completed {
                completion(outputURL)
            } else {
                completion(nil)
            }
        }
    }
    
    private static func pixelBuffer(from image: UIImage, size: CGSize) -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        guard let ctx = context else { return nil }
        
        UIGraphicsPushContext(ctx)
        ctx.translateBy(x: 0, y: size.height)
        ctx.scaleBy(x: 1, y: -1)
        
        let rect = CGRect(origin: .zero, size: size)
        ctx.clear(rect)
        
        let aspectWidth = size.width / image.size.width
        let aspectHeight = size.height / image.size.height
        let aspectRatio = max(aspectWidth, aspectHeight)
        
        let scaledWidth = image.size.width * aspectRatio
        let scaledHeight = image.size.height * aspectRatio
        let x = (size.width - scaledWidth) / 2
        let y = (size.height - scaledHeight) / 2
        
        image.draw(in: CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight))
        UIGraphicsPopContext()
        
        return buffer
    }
}
