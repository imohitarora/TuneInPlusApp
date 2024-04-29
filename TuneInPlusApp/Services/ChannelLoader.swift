//  ChannelLoader.swift
import Foundation

struct ChannelLoader {
    static let channels: [Channel] = {
        // Get the URL for the JSON file in the bundle
        guard let url = Bundle.main.url(forResource: "channels", withExtension: "json") else {
            print("Channels JSON file not found")
            return []
        }
        
        do {
            // Read data from the file
            let data = try Data(contentsOf: url)
            
            // Deserialize the JSON into Swift objects
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            // Ensure the JSON is in the expected format of [[String: String]]
            guard let jsonArray = json as? [[String: String]] else {
                print("Invalid JSON structure")
                return []
            }
            
            // Map the dictionaries to Channel objects, safely handling URLs
            return jsonArray.compactMap { dict in
                guard let name = dict["name"], let urlString = dict["url"], let url = URL(string: urlString) else {
                    print("Invalid data in JSON")
                    return nil
                }
                return Channel(name: name, url: url)
            }
        } catch {
            // Handle any errors during the reading or parsing process
            print("Error loading channels from JSON: \(error.localizedDescription)")
            return []
        }
    }()
}
