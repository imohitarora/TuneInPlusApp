//
//  PlayerManager.swift
//  TuneInPlusApp
//
//  Created by Mohit Arora on 2024-04-26.
//

import Foundation
import AVFoundation

class AudioPlayer: ObservableObject {
    var player = AVPlayer()

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func stop() {
        player.pause()
        player.seek(to: .zero)
    }

    func replaceCurrentItem(with: AVPlayerItem) {
        player.replaceCurrentItem(with: with)
    }
}
