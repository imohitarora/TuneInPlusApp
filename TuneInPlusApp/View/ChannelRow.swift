//
//  ChannelRow.swift
//  TuneInPlusApp
//
//  Created by Mohit Arora on 2024-04-26.
//

import SwiftUI

struct ChannelRow: View {
    var channel: Channel
    var isPlaying: Bool
    var isFavourite: Bool
    var togglePlay: ((Channel) -> Void)?
    var toggleFavorite: ((Channel) -> Void)?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(channel.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text(channel.meta ?? "")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .onTapGesture {
                togglePlay?(channel)
            }
            
            Spacer()
            Button(action: {
                toggleFavorite?(channel)
            }) {
                Image(systemName: isFavourite ? "heart.fill" : "heart")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                togglePlay?(channel)
            }) {
                Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(isPlaying ? Color("PlayingBackground").opacity(0.2) : Color("IdleBackground").opacity(0.5))
        .cornerRadius(10)
    }
    
    // Function to return Color based on playing state
    private func background(for isPlaying: Bool) -> Color {
        return isPlaying ? Color("PlayingBackground").opacity(0.2) : Color("IdleBackground").opacity(0.5)
    }
}

#Preview {
    ChannelRow(channel: Channel(name: "CMR Toronto", url: URL(string: "https://live.cmr24.net/CMR/Punjabi-MQ/icecast.audio")!, meta: "INDIA"), isPlaying: false, isFavourite: false)
}
