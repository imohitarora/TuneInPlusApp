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
    
    var body: some View {
        TabView {
            PlayPad(audioPlayer: audioPlayer, isShowingFavorites: false)
                .tabItem {
                    Label("All Channels", systemImage: "radio")
                }
            PlayPad(audioPlayer: audioPlayer, isShowingFavorites: true)
                .tabItem {
                    Label("Favourites", systemImage: "heart")
                }
        }
    }
}

#Preview {
    ContentView(audioPlayer: AudioPlayer())
}
