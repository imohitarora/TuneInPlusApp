//
//  TuneInPlusApp.swift
//  TuneInPlusApp
//
//  Created by Mohit Arora on 2024-04-26.
//

import SwiftUI
import MediaPlayer

@main
struct TuneInPlusApp: App {
    @StateObject var audioPlayer = AudioPlayer()
    let channelManager = ChannelManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(audioPlayer: audioPlayer)
                .onAppear {
                    // Configure audio session for background playback
                    do {
                        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                        try AVAudioSession.sharedInstance().setActive(true)
                    } catch {
                        print("Error setting up audio session: \(error)")
                    }
                    
                    // Handle remote commands
                    let commandCenter = MPRemoteCommandCenter.shared()
                    commandCenter.playCommand.addTarget { _ in
                        channelManager.startPlayback(for: channelManager.channels[channelManager.currentChannelIndex])
                        return .success
                    }
                    commandCenter.pauseCommand.addTarget { _ in
                        channelManager.stopPlayback()
                        return .success
                    }
                    commandCenter.previousTrackCommand.addTarget { _ in
                        channelManager.previousChannel()
                        return .success
                    }
                    commandCenter.nextTrackCommand.addTarget { _ in
                        channelManager.nextChannel()
                        return .success
                    }
                }
        }
    }
}

