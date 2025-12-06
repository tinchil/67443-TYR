//
//  PixelBufferRendererTests.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/6/25.
//


import Testing
import UIKit
@testable import Saturdays

struct PixelBufferRendererTests {

    @Test
    func testCreatesNonNilPixelBuffer() throws {
        let image = UIImage(systemName: "star")!
        let size = CGSize(width: 300, height: 500)

        let buffer = PixelBufferRenderer.createPixelBuffer(from: image, size: size)

        #expect(buffer != nil)
    }

    @Test
    func testPixelBufferHasCorrectDimensions() throws {
        let image = UIImage(systemName: "star")!
        let size = CGSize(width: 400, height: 600)

        let buffer = try #require(
            PixelBufferRenderer.createPixelBuffer(from: image, size: size)
        )

        let width = CVPixelBufferGetWidth(buffer)
        let height = CVPixelBufferGetHeight(buffer)

        #expect(width == Int(size.width))
        #expect(height == Int(size.height))
    }

    @Test
    func testPixelBufferIsARGBFormat() throws {
        let image = UIImage(systemName: "star")!
        let size = CGSize(width: 200, height: 200)

        let buffer = try #require(
            PixelBufferRenderer.createPixelBuffer(from: image, size: size)
        )

        let format = CVPixelBufferGetPixelFormatType(buffer)

        #expect(format == kCVPixelFormatType_32ARGB)
    }
}
