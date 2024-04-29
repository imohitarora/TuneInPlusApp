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
    
    @State private var currentPlayer: Channel?
    
    @State private var isPlaying = false
    
    let isShowingFavorites: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationView {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 1) {
                        ForEach(isShowingFavorites ? channelManager.favoriteChannels : channelManager.channels, id: \.self) { channel in
                            ChannelRow(channel: channel, isPlaying: channelManager.playingChannels[channel, default: false], togglePlay: togglePlay, toggleFavorite: channelManager.toggleFavorite)
                                .padding(.vertical, 5)
                                .cornerRadius(15)
                                .shadow(color: Color("Shadow"), radius: 5, x: 0, y: 2)
                        }
                    }
                    .onAppear {
                        channelManager.loadFavoriteChannels()
                    }
                    .padding(.horizontal)
                    .background(Color("Background"))
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
                        currentChannel: currentPlayer,
                        playPauseAction: {
                            togglePlay(for: currentPlayer!)
                        },
                        nextAction: nextChannel,
                        previousAction: previousChannel
                    )
                    .frame(maxWidth: .infinity)
                    .background(Color("Background"))
                    .shadow(color: Color("Shadow"), radius: 5, x: 0, y: 2)
                }
            }
        }
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

#Preview {
    PlayPad(isShowingFavorites: true)
}
