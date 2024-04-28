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
    
    var channels: [Channel] = [
        Channel(name: "Air Vividh Bharti", url: URL(string: "https://air.pc.cdn.bitgravity.com/air/live/pbaudio001/playlist.m3u8")!),
        Channel(name: "RED FM Mumbai", url: URL(string: "https://funasia.streamguys1.com/live9")!),
        Channel(name: "RED FM Toronto", url: URL(string: "https://ice9.securenetsystems.net/CIRVFM")!),
        Channel(name: "Radio City Mumbai", url: URL(string: "https://prclive4.listenon.in/Hindi")!),
        Channel(name: "AIR - Suratgarh", url: URL(string: "https://air.pc.cdn.bitgravity.com/air/live/pbaudio064/chunklist.m3u8")!),
        Channel(name: "Ishq FM", url: URL(string: "https://prclive4.listenon.in/Ishq")!),
        Channel(name: "Punjabi FM", url: URL(string: "https://prclive4.listenon.in/Punjabi")!),
        Channel(name: "Brit Asia", url: URL(string: "https://s4.radio.co/sfefce156f/listen")!),
        Channel(name: "CRIF Brampton", url: URL(string: "https://ice66.securenetsystems.net/CIRF")!),
        Channel(name: "CMR Toronto", url: URL(string: "https://live.cmr24.net/CMR/Punjabi-MQ/icecast.audio")!),
        Channel(name: "Jaipur Radio", url: URL(string: "https://streamasiacdn.atc-labs.com/jaipurradio.aac")!),
        Channel(name: "Radio Mirchi - NC, USA", url: URL(string: "https://streams.radio.co/s8d06d0298/listen")!),
    ]
    
    @Published var playingChannels: [Channel: Bool] = [:]
    @Published var currentChannelIndex = -1 {
        didSet {
            if currentChannelIndex != -1 {
                playingChannels[channels[currentChannelIndex]] = true
            }
        }
    }
    
    let nowPlayingInfo = MPNowPlayingInfoCenter.default()
    
    func updateNowPlayingInfo() {
        if currentChannelIndex != -1 {
            let currentChannel = channels[currentChannelIndex]
            nowPlayingInfo.nowPlayingInfo = [
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
}
