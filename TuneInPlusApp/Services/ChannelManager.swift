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
    var currentPlayer: Channel?
    
    var channels: [Channel] = ChannelLoader.channels
    
    @Published var playingChannels: [Channel: Bool] = [:]
    
    @Published var currentChannelIndex = -1 {
        didSet {
            if currentChannelIndex != -1 {
                playingChannels[channels[currentChannelIndex]] = true
            }
        }
    }
    
    @Published var favoriteChannels: [Channel] = []
    
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
    
    func loadChannelsFromJSON() -> [Channel] {
        guard let url = Bundle.main.url(forResource: "channels", withExtension: "json", subdirectory: "Data") else {
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonArray = json as? [[String: String]] else {
                return []
            }
            return jsonArray.compactMap { Channel(name: $0["name"] ?? "", url: URL(string: $0["url"] ?? "")!) }
        } catch {
            print("Error loading channels from JSON: \(error.localizedDescription)")
            return []
        }
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
        } else {
            nowPlayingInfo.nowPlayingInfo = [
                MPMediaItemPropertyTitle: "No Channel Selected",
                MPMediaItemPropertyArtist: "",
                MPNowPlayingInfoPropertyPlaybackRate: 1.0,
                MPNowPlayingInfoPropertyIsLiveStream: true
            ]
        }
    }
    
    func startPlayback(for channel: Channel) {
        print("Starting playback for channel: \(channel.name)")
        if let currentChannel = currentPlayer {
            playingChannels[currentChannel] = false
        }
        let playerItem = AVPlayerItem(url: channel.url)
        audioPlayer.replaceCurrentItem(with: playerItem)
        audioPlayer.play()
        playingChannels[channel] = true
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
        if let currentChannel = currentPlayer {
            playingChannels[currentChannel] = false
        }
        
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
        if let index = favoriteChannels.firstIndex(where: { $0.name == channel.name }) {
            favoriteChannels.remove(at: index)
            print("Removed from favorites")
            if let index = channels.firstIndex(of: channel) {
                channels[index].isFavorite = false
            }
        } else {
            print("Added to favorites")
            favoriteChannels.append(channel)
            if let index = channels.firstIndex(of: channel) {
                channels[index].isFavorite = true
            }
            if let index = favoriteChannels.firstIndex(of: channel) {
                favoriteChannels[index].isFavorite = true
            }
        }
        print(favoriteChannels.map { $0.name })
        saveFavoriteChannels()
    }
    
    func saveFavoriteChannels() {
        let favoriteChannelsData = favoriteChannels.map { try? JSONEncoder().encode($0) }
        UserDefaults.standard.set(favoriteChannelsData, forKey: "favoriteChannels")
    }
    
    func loadFavoriteChannels() {
        if let favoriteChannelsData = UserDefaults.standard.array(forKey: "favoriteChannels") as? [Data] {
            favoriteChannels = favoriteChannelsData.compactMap { try? JSONDecoder().decode(Channel.self, from: $0) }
        }
    }
}
