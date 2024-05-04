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
    var isShowingFavouritesTab: Bool
    var togglePlay: ((Channel) -> Void)?
    var toggleFavorite: ((Channel) -> Void)?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(channel.name)
                    .lineLimit(1)
                    .font(.subheadline)
                    .textCase(.uppercase)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                HStack {
                    Text("(\(channel.country.trimmingCharacters(in: .whitespaces))) -")
                    Text(channel.meta?.trimmingCharacters(in: .whitespaces) ?? "")
                }
                .lineLimit(1)
                .font(.caption2)
                .foregroundColor(.secondary)
                
            }
            .onTapGesture {
                togglePlay?(channel)
            }
            
            Spacer()
            if isShowingFavouritesTab {
                Button(action: {
                    toggleFavorite?(channel)
                }) {
                    Image(systemName: isFavourite ? "heart.fill" : "heart")
                        .resizable()
                        .font(.title)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 30)
                        .foregroundColor(.blue.opacity(0.9))
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Button(action: {
                    togglePlay?(channel)
                }) {
                    Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                        .resizable()
                        .font(.caption)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue.opacity(0.9))
                }
                .buttonStyle(PlainButtonStyle())
            }
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
    ChannelRow(channel: Channel(id: "3a8156f0-f829-489f-b506-2aab705aa7f5", name: "CMR Toronto", url: URL(string: "https://live.cmr24.net/CMR/Punjabi-MQ/icecast.audio")!, country: "IN", meta: "INDIA"), isPlaying: false, isFavourite: false, isShowingFavouritesTab: true)
}
