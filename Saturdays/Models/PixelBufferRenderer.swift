//
//  PixelBufferRenderer.swift
//  Saturdays
//
//  Created by Rosemary Yang on 10/26/25.
//


import UIKit
import AVFoundation

class PixelBufferRenderer {
    static func createPixelBuffer(from image: UIImage, size: CGSize) -> CVPixelBuffer? {
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
        
        guard let ctx = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else { return nil }
        
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
