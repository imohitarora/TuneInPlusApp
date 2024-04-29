//
//  PlaybackControls.swift
//  TuneInPlusApp
//
//  Created by Mohit Arora on 2024-04-26.
//

import SwiftUI

struct PlaybackControls: View {
    let isPlaying: Bool
    var isFavourite: Bool
    let currentChannel: Channel?
    let playPauseAction: () -> Void
    let nextAction: () -> Void
    let previousAction: () -> Void
    let toggleFavorite: (Channel) -> Void // Add this line
    
    var body: some View {
        HStack {
            // Now Playing information
            Image(systemName: isFavourite ? "heart.fill" : "heart")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)
                .onTapGesture {
                    if let currentChannel = currentChannel {
                        toggleFavorite(currentChannel)
                    }
                }
            VStack(alignment: .leading) {
                Text("Now Playing:")
                    .font(.caption)
                Text(currentChannel?.name ?? "Song Title - Artist Name")
                    .font(.headline)
            }
            Spacer()
            // Playback controls
            HStack {
                Button(action: previousAction) {
                    Image(systemName: "backward.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                }
                Button(action: playPauseAction) {
                    Image(systemName: isPlaying ? "stop.circle" : "play.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                }
                Button(action: nextAction) {
                    Image(systemName: "forward.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                }
            }
        }
        .padding()
        .cornerRadius(10)
        .shadow(color: Color("Shadow"), radius: 5, x: 0, y: 2)
    }
}
