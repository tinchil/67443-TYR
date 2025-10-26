//
//  VideoPlayerView.swift
//  Saturdays
//
//  Created by Rosemary Yang on 9/29/25.
//

import SwiftUI
import AVFoundation

struct VideoPlayerView: View {
    let url: URL
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VideoPlayer(player: AVPlayer(url: url))
                .navigationTitle("Preview")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}
