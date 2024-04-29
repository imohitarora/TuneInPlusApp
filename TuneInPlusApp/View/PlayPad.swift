//
//  PlayPad.swift
//  TuneInPlusApp
//
//  Created by Mohit Arora on 2024-04-26.
//

import SwiftUI
import AVFoundation

struct PlayPad: View {
    @StateObject var audioPlayer = AudioPlayer()
    
    @ObservedObject var channelManager = ChannelManager.shared // Add this line
    
    @Binding var currentPlayer: Channel?
    
    @Binding var isPlaying: Bool
    
    @State private var isFavourite = false
    
    let isShowingFavorites: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationView {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 1) {
                        ForEach(isShowingFavorites ? channelManager.favoriteChannels : channelManager.channels, id: \.self) { channel in
                            ChannelRow(channel: channel, isPlaying: channelManager.playingChannels[channel, default: false],  isFavourite: channelManager.favoriteChannels.contains(channel),  togglePlay: togglePlay, toggleFavorite: toggleFavorite)
                                .padding(.vertical, 5)
                                .cornerRadius(15)
                                .shadow(color: Color("Shadow"), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    .background(Color("Background"))
                }
                .onAppear {
                    channelManager.loadFavoriteChannels()
                }
                .padding(.bottom, isPlaying ? 70 : 0) // Add this
                .navigationTitle("Radio Channels")
                .navigationBarTitleDisplayMode(.large)
                .background(Color("Background").edgesIgnoringSafeArea(.all))
            }
            if isPlaying {
                Spacer()
                withAnimation(.easeInOut) {
                    PlaybackControls(
                        isPlaying: isPlaying,
                        isFavourite: (currentPlayer != nil) ? channelManager.favoriteChannels.contains(currentPlayer!) : false,
                        currentChannel: currentPlayer,
                        playPauseAction: {
                            togglePlay(for: currentPlayer!)
                        },
                        nextAction: nextChannel,
                        previousAction: previousChannel,
                        toggleFavorite: toggleFavorite
                    )
                    .frame(maxWidth: .infinity)
                    .background(Color("Background"))
                    .shadow(color: Color("Shadow"), radius: 5, x: 0, y: 2)
                }
            }
        }
    }
    
    private func toggleFavorite(for channel: Channel) {        
        channelManager.toggleFavorite(channel: channel)
    }
    
    private func togglePlay(for channel: Channel) {
        if channelManager.playingChannels[channel, default: false] {
            channelManager.stopPlayback()
            currentPlayer = nil
            isPlaying = false
        } else {
            if let index = channelManager.channels.firstIndex(of: channel) {
                channelManager.currentChannelIndex = index
            }
            channelManager.startPlayback(for: channel)
            currentPlayer = channel
            isPlaying = true
        }
    }
    
    private func nextChannel() {
        channelManager.nextChannel()
        currentPlayer = channelManager.channels[channelManager.currentChannelIndex]
    }
    
    private func previousChannel() {
        channelManager.previousChannel()
        currentPlayer = channelManager.channels[channelManager.currentChannelIndex]
    }
}

