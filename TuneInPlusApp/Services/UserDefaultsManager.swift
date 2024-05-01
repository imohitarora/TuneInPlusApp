//
//  UserDefaultsManager.swift
//  TuneInPlusApp
//
//  Created by Mohit Arora on 2024-04-30.
//

import Foundation

struct UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard

    private let channelsKey = "StoredChannels"
    private let favoriteChannelsKey = "favoriteChannels"

    func saveChannels(_ channels: [Channel]) {
        do {
            let data = try JSONEncoder().encode(channels)
            defaults.set(data, forKey: channelsKey)
            print("Channels successfully saved to UserDefaults")
        } catch {
            print("Failed to encode and save channels: \(error)")
        }
    }

    func loadChannels() -> Result<[Channel], Error> {
        guard let data = defaults.data(forKey: channelsKey) else {
            return .failure(NSError(domain: "ChannelLoader", code: 404, userInfo: [NSLocalizedDescriptionKey: "No data found in UserDefaults for channels"]))
        }
        do {
            let channels = try JSONDecoder().decode([Channel].self, from: data)
            return .success(channels)
        } catch {
            return .failure(error)
        }
    }

    func resetChannels() {
        defaults.removeObject(forKey: channelsKey)
        print("Stored channels have been reset")
    }

    func saveFavoriteChannels(_ channels: [Channel]) {
        do {
            let data = try JSONEncoder().encode(channels)
            defaults.set(data, forKey: favoriteChannelsKey)
            print("Favorite channels successfully saved to UserDefaults")
        } catch {
            print("Failed to encode and save favorite channels: \(error)")
        }
    }

    func loadFavoriteChannels() -> Result<[Channel], Error> {
        guard let data = UserDefaults.standard.data(forKey: favoriteChannelsKey) else {
            return .failure(NSError(domain: "ChannelLoader", code: 404, userInfo: [NSLocalizedDescriptionKey: "No data found in UserDefaults for favorite channels"]))
        }
        do {
            let channels = try JSONDecoder().decode([Channel].self, from: data)
            return .success(channels)
        } catch {
            print("Entered in catch - Lets do the fav magic: \(error)")
            // Transform existing data to new model
            if let existingData = UserDefaults.standard.data(forKey: favoriteChannelsKey) {
                let jsonArray = try? JSONSerialization.jsonObject(with: existingData, options: [])
                if let jsonChannels = jsonArray as? [[String: Any]] {
                    var newChannels: [Channel] = []
                    for jsonChannel in jsonChannels {
                        if let name = jsonChannel["name"] as? String, let channel = ChannelManager.shared.channels.first(where: { $0.name == name }) {
                            newChannels.append(channel)
                        }
                    }
                    resetFavoriteChannels()
                    UserDefaults.standard.set(try? JSONEncoder().encode(newChannels), forKey: favoriteChannelsKey)
                    print("Existing favorite channels have been migrated to new model")
                }
            }
            return .failure(error)
        }
    }

    func resetFavoriteChannels() {
        defaults.removeObject(forKey: favoriteChannelsKey)
        print("Stored favorite channels have been reset")
    }
}
