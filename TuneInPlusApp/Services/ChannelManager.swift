//
//  ChannelManager.swift
//  TuneInPlusApp
//
//  Created by Mohit Arora on 2024-04-26.
//

import Foundation
import AVFoundation
import MediaPlayer
import Combine


class ChannelManager: ObservableObject {
    static let shared = ChannelManager()
    
    var audioPlayer = AudioPlayer()
    
    @Published var currentPlayer: Channel?
    
    @Published var channels: [Channel] = ChannelLoader.channels
    
    @Published var currentChannelIndex = -1
    
    @Published var favoriteChannels: [Channel] = []
    
    @Published var isPlaying = false
    
    @Published var selectedOption: Int? = nil {
        didSet {
            resetTimer()
        }
    }
    
    private var timer: Timer?
    
    
    let nowPlayingInfo = MPNowPlayingInfoCenter.default()
    
    init() {
        loadAndSortChannels()
    }
    
    var currentPlaylist : [Channel] = []
    
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
            let currentChannel = currentPlaylist[currentChannelIndex]
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
        if let index = currentPlaylist.firstIndex(where: { $0.id == channel.id}) {
            currentChannelIndex = index
        }
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
        // Stop the player if it is currently playing
        if isPlaying {
            audioPlayer.stop()
            isPlaying = false
            print("Playback stopped.")
        } else {
            print("No playback to stop.")
        }

        // Clear the current player only if necessary
        if currentPlayer != nil {
            currentPlayer = nil
            print("Cleared the current player.")
        }

        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Error stopping audio session: \(error)")
        }
    }
    
    func nextChannel() {
        currentChannelIndex = (currentChannelIndex + 1) % currentPlaylist.count
        startPlayback(for: currentPlaylist[currentChannelIndex])
        updateNowPlayingInfo()
    }
    
    func previousChannel() {
        currentChannelIndex = (currentChannelIndex - 1 + currentPlaylist.count) % currentPlaylist.count
        startPlayback(for: currentPlaylist[currentChannelIndex])
        updateNowPlayingInfo()
    }
    
    func toggleFavorite(channel: Channel) {
        print("toggleFavorite clicked")
        if let index = favoriteChannels.firstIndex(where: { $0.id == channel.id})  {
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
    
    func resetTimer() {
        // Invalidate the current timer if it exists
        timer?.invalidate()
        print("Existing timer invalidated")
        
        // Set up a new timer if a valid option is selected
        if let interval = selectedOption {
            print("Setting up a timer for \(interval * 15) minutes")
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval * 15 * 60), repeats: false) { [weak self] _ in
                self?.timerAction()
            }
        } else {
            print("No valid interval selected; no timer set.")
        }
    }
    
    private func timerAction() {
        // Perform the action after the timer completes
        print("Timer completed for \(selectedOption ?? 0) minutes.")
        stopPlayback()
        DispatchQueue.main.async {
            self.selectedOption = nil // Reset the selection once the timer completes
        }
    }
    
    deinit {
        // Make sure to invalidate the timer when this object is deallocated
        timer?.invalidate()
        print("Timer invalidated on deinit")
    }
    
    private func loadAndSortChannels() {
        // Assuming ChannelLoader.channels loads unsorted channels
        let unsortedChannels = ChannelLoader.channels
        let userCountryCode = Locale.current.region?.identifier.lowercased() ?? ""

        channels = unsortedChannels.sorted {
            let isLocale0 = $0.country.lowercased() == userCountryCode
            let isLocale1 = $1.country.lowercased() == userCountryCode
            if isLocale0 && !isLocale1 {
                return true
            } else if !isLocale0 && isLocale1 {
                return false
            } else {
                return $0.name < $1.name
            }
        }
    }
}
