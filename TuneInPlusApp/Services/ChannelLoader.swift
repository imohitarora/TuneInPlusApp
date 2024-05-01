//  ChannelLoader.swift
import Foundation

struct ChannelLoader {
    static let channels: [Channel] = {
        switch UserDefaultsManager.shared.loadChannels() {
        case .success(let storedChannels):
            print("Channels loaded from UserDefaults")
            return storedChannels
        case .failure(let error):
            print("Error loading channels from UserDefaults: \(error). Resetting and attempting to reload from JSON.")
            UserDefaultsManager.shared.resetChannels()  // Reset the channels
            return loadChannelsFromJSON() ?? []
        }
    }()

    private static func loadChannelsFromJSON() -> [Channel]? {
        guard let url = Bundle.main.url(forResource: "channels", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("JSON file URL is nil or the file could not be read")
            return nil
        }

        do {
            let channels = try JSONDecoder().decode([Channel].self, from: data)
            UserDefaultsManager.shared.saveChannels(channels)
            print("Channels successfully decoded from JSON and saved")
            return channels
        } catch {
            print("Error decoding channels from JSON: \(error)")
            return nil
        }
    }
}

