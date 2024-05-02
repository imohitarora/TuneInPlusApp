//
//  ContentView.swift
//  TuneInPlusApp
//
//  Created by Mohit Arora on 2024-04-26.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject var audioPlayer: AudioPlayer
    @ObservedObject var viewModel = ChannelManager.shared

    var body: some View {
        TabView {
            PlayPad(audioPlayer: audioPlayer, isShowingFavorites: false) // Pass the binding
                .tabItem {
                    Label("All Channels", systemImage: "radio")
                }
            PlayPad(audioPlayer: audioPlayer, isShowingFavorites: true) // Pass the binding
                .tabItem {
                    Label("Favourites", systemImage: "heart")
                }
            SleepOptionsView()
                .tabItem {
                    Label("Sleep", systemImage: viewModel.selectedOption == nil ? "moon.stars" : "moon.zzz")
                }
        }
    }
}

#Preview {
    ContentView(audioPlayer: AudioPlayer())
}
