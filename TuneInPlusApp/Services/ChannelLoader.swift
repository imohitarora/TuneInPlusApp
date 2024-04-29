//  ChannelLoader.swift
import Foundation

struct ChannelLoader {
    static let channels: [Channel] = {
        guard let url = Bundle.main.url(forResource: "channels", withExtension: "json") else {
            print("file not found")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonArray = json as? [[String: String]] else {
                return []
            }
            return jsonArray.compactMap { Channel(name: $0["name"] ?? "", url: URL(string: $0["url"] ?? "")!) }
        } catch {
            print("Error loading channels from JSON: \(error.localizedDescription)")
            return []
        }
    }()
}
