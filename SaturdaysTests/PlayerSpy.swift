//
//  PlayerSpy.swift
//  Saturdays
//
//  Created by Rosemary Yang on 12/11/25.
//


import AVKit

final class PlayerSpy: AVPlayer {
    private(set) var playCalled = false
    private(set) var pauseCalled = false

    override func play() { playCalled = true }
    override func pause() { pauseCalled = true }
}
