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
    
    @ObservedObject var channelManager = ChannelManager.shared
    
    @State private var isFavourite = false
    
    @State private var searchQuery = ""
    
    @FocusState private var isFocused: Bool
    
    let isShowingFavorites: Bool
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationView {
                ScrollView(.vertical, showsIndicators: false) {
                    SearchBar(text: $searchQuery)
                        .padding(.horizontal)
                        .padding(.top)
                        .focused($isFocused)
                    
                    LazyVStack(spacing: 1) {
                        ForEach(setChannelList() , id: \.self) { channel in
                            ChannelRow(channel: channel, isPlaying: checkPlaying(channel: channel),  isFavourite: checkFavorite(channel: channel), isShowingFavouritesTab: isShowingFavorites,  togglePlay: togglePlay, toggleFavorite: toggleFavorite)
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
                .onChange(of: searchQuery) {
                    if searchQuery.isEmpty {
                        isFocused = false
                    }
                }
                .padding(.bottom, channelManager.isPlaying ? 70 : 0)
                .navigationTitle("Radio Channels")
                .navigationBarTitleDisplayMode(.large)
                .background(Color("Background").edgesIgnoringSafeArea(.all))
            }
            if channelManager.isPlaying {
                Spacer()
                withAnimation(.easeInOut) {
                    PlaybackControls(
                        isPlaying: channelManager.isPlaying,
                        isFavourite: (channelManager.currentPlayer != nil) ? channelManager.favoriteChannels.contains(channelManager.currentPlayer!) : false,
                        currentChannel: channelManager.currentPlayer,
                        playPauseAction: {
                            togglePlay(for: channelManager.currentPlayer!)
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
    
    func setChannelList() -> [Channel] {
        if isShowingFavorites {
            return channelManager.favoriteChannels.filter { searchQuery.isEmpty ? true : $0.name.lowercased().contains(searchQuery.lowercased()) }
        } else {
            return channelManager.channels.filter { searchQuery.isEmpty ? true : $0.name.lowercased().contains(searchQuery.lowercased()) }
        }
    }
    
    func checkFavorite(channel: Channel) -> Bool {
        return channelManager.favoriteChannels.contains(channel)
    }
    
    func checkPlaying(channel: Channel) -> Bool {
        return channelManager.currentPlayer != nil && channel == channelManager.currentPlayer
    }
    
    private func toggleFavorite(for channel: Channel) {
        channelManager.toggleFavorite(channel: channel)
    }
    
    private func togglePlay(for channel: Channel) {
        print(channel)
        if channelManager.currentPlayer == channel && channelManager.isPlaying {
            channelManager.stopPlayback()
        } else {
            if let index = channelManager.channels.firstIndex(of: channel) {
                channelManager.currentChannelIndex = index
            }
            channelManager.startPlayback(for: channel)
        }
    }
    
    private func nextChannel() {
        channelManager.nextChannel()
    }
    
    private func previousChannel() {
        channelManager.previousChannel()
    }
}

