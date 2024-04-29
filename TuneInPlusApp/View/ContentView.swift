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
    @State private var isPlaying = false // Move the state here
    @State private var currentPlayer: Channel?
    
    var body: some View {
            TabView {
                PlayPad(audioPlayer: audioPlayer, currentPlayer: $currentPlayer, isPlaying: $isPlaying, isShowingFavorites: false) // Pass the binding
                    .tabItem {
                        Label("All Channels", systemImage: "radio")
                    }
                PlayPad(audioPlayer: audioPlayer, currentPlayer: $currentPlayer, isPlaying: $isPlaying, isShowingFavorites: true) // Pass the binding
                    .tabItem {
                        Label("Favourites", systemImage: "heart")
                    }
            }
        }
}

#Preview {
    ContentView(audioPlayer: AudioPlayer())
}
