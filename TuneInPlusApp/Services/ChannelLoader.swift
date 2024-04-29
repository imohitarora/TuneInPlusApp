//  ChannelLoader.swift
import Foundation

struct ChannelLoader {
    static let channels: [Channel] = {
        let userDefaultsKey = "StoredChannels"

        // Try to retrieve and decode channels from UserDefaults
        if let storedChannelsData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let storedChannels = try? JSONDecoder().decode([Channel].self, from: storedChannelsData) {
            print("Loading channels locally")
            return storedChannels
        } else {
            // Load from JSON file if not available in UserDefaults
            guard let url = Bundle.main.url(forResource: "channels", withExtension: "json") else {
                print("Channels JSON file not found")
                return []
            }

            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let channels = try decoder.decode([Channel].self, from: data)

                // Save the newly created channels to UserDefaults
                if let encoded = try? JSONEncoder().encode(channels) {
                    UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
                }

                return channels
            } catch {
                print("Error loading channels from JSON: \(error)")
                return []
            }
        }
    }()
}
