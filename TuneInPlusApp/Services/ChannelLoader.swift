//  ChannelLoader.swift
import Foundation

struct ChannelLoader {
    static let channels: [Channel] = {
        checkForChannelUpdates()
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
    
    private static func checkForChannelUpdates() {
        print("Checking for channel updates...")
        guard let url = Bundle.main.url(forResource: "channels", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("JSON file URL is nil or the file could not be read")
            return
        }
        
        do {
            // Decode the channels from the JSON data
            let jsonChannels = try JSONDecoder().decode([Channel].self, from: data)
            
            // Calculate the hash value for the JSON channels
            let jsonHash = jsonChannels.map(\.hashValue).reduce(0, ^) // Use XOR for combining hash values
            
            // Retrieve the stored channels from UserDefaults
            let storedChannelsResult = UserDefaultsManager.shared.loadChannels()
            
            switch storedChannelsResult {
            case .success(let storedChannels):
                // Calculate the hash value for the stored channels
                let storedHash = storedChannels.map(\.hashValue).reduce(0, ^) // Use XOR for combining hash values
                
                // Check if the hash values are different
                if jsonHash != storedHash {
                    // If the hashes are different, reset and reload the channels
                    UserDefaultsManager.shared.resetChannels()
                    UserDefaultsManager.shared.saveChannels(jsonChannels)
                    print("Channels updated and saved")
                } else {
                    print("Channels are up to date")
                }
            case .failure(let error):
                print("Failed to load channels from UserDefaults: \(error)")
                // Optionally, handle error by resetting to defaults or other fallbacks
            }
        } catch {
            print("Error decoding channels from JSON: \(error)")
        }
    }
    
}

