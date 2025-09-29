//
//  VideoPlayer.swift
//  Saturdays
//
//  Created by Rosemary Yang on 9/29/25.
//

import SwiftUI
import AVKit

struct VideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.player?.play()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
