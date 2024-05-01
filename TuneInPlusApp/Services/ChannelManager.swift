//
//  ChannelManager.swift
//  TuneInPlusApp
//
//  Created by Mohit Arora on 2024-04-26.
//

import Foundation
import AVFoundation
import MediaPlayer


class ChannelManager: ObservableObject {
    static let shared = ChannelManager()
    
    var audioPlayer = AudioPlayer()
    
    @Published var currentPlayer: Channel?
    
    @Published var channels: [Channel] = ChannelLoader.channels
    
    @Published var currentChannelIndex = -1
    
    @Published var favoriteChannels: [Channel] = []
    
    @Published var isPlaying = false
    
    let nowPlayingInfo = MPNowPlayingInfoCenter.default()
    
    
    func GetAppIcon() -> UIImage {
        var appIcon: UIImage! {
            guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String:Any],
                  let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String:Any],
                  let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
                  let lastIcon = iconFiles.last else { return nil }
            return UIImage(named: lastIcon)
        }
        return appIcon
    }
    
    func updateNowPlayingInfo() {
        if currentChannelIndex != -1 {
            let currentChannel = channels[currentChannelIndex]
            nowPlayingInfo.nowPlayingInfo = [
                MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: CGSize(width: 80, height: 80)) { size in
                    return self.GetAppIcon()
                },
                MPMediaItemPropertyTitle: currentChannel.name,
                MPMediaItemPropertyArtist: currentChannel.url, // Update with actual artist name
                MPNowPlayingInfoPropertyPlaybackRate: 1.0,
                MPNowPlayingInfoPropertyIsLiveStream: true                
            ]
            
            let commandCenter = MPRemoteCommandCenter.shared()
            commandCenter.likeCommand.isActive = checkFavorite()
        } else {
            nowPlayingInfo.nowPlayingInfo = [
                MPMediaItemPropertyTitle: "No Channel Selected",
                MPMediaItemPropertyArtist: "",
                MPNowPlayingInfoPropertyPlaybackRate: 1.0,
                MPNowPlayingInfoPropertyIsLiveStream: true
            ]
            
            let commandCenter = MPRemoteCommandCenter.shared()
            commandCenter.likeCommand.isEnabled = false
        }
    }
    
    func startPlayback(for channel: Channel) {
        print("Starting playback for channel: \(channel.name)")
        let playerItem = AVPlayerItem(url: channel.url)
        audioPlayer.replaceCurrentItem(with: playerItem)
        audioPlayer.play()
        isPlaying = true
        currentPlayer = channel
        
        updateNowPlayingInfo()
        
        // Add the following lines to start playback in background
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    func stopPlayback() {
        audioPlayer.stop()
        isPlaying = false
        currentPlayer = nil
        // Add the following lines to stop playback in background
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Error stopping audio session: \(error)")
        }
    }
    
    func nextChannel() {
        currentChannelIndex = (currentChannelIndex + 1) % channels.count
        startPlayback(for: channels[currentChannelIndex])
        updateNowPlayingInfo()
    }
    
    func previousChannel() {
        currentChannelIndex = (currentChannelIndex - 1 + channels.count) % channels.count
        startPlayback(for: channels[currentChannelIndex])
        updateNowPlayingInfo()
    }
    
    func toggleFavorite(channel: Channel) {
        print("toggleFavorite clicked")
        if let index = favoriteChannels.firstIndex(of: channel) {
            favoriteChannels.remove(at: index)
            print("Removed from favorites")
        } else {
            print("Added to favorites")
            favoriteChannels.append(channel)
        }
        UserDefaultsManager.shared.saveFavoriteChannels(favoriteChannels)
        updateNowPlayingInfo()
    }
    
    func loadFavoriteChannels() {
        do {
            switch UserDefaultsManager.shared.loadFavoriteChannels() {
            case .success(let channels):
                favoriteChannels = channels
            case .failure(let error):
                print("Error loading favorite channels: \(error)")
            }
        }
    }
    
    func checkFavorite() -> Bool {
        return currentPlayer != nil ? favoriteChannels.contains(currentPlayer!) : false
    }
}
