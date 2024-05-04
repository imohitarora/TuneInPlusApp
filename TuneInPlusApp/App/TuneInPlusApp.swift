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
                    configureAudioSession()
                    handleRemoteCommand()
                }
        }
    }
    
    func configureAudioSession() {
        // Configure audio session for background playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    func handleRemoteCommand() {
        // Handle remote commands
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { _ in
            channelManager.startPlayback(for: channelManager.currentPlaylist[channelManager.currentChannelIndex])
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
        commandCenter.likeCommand.addTarget { _ in
            channelManager.toggleFavorite(channel: channelManager.currentPlaylist[channelManager.currentChannelIndex])
            return .success
        }
    }
}

