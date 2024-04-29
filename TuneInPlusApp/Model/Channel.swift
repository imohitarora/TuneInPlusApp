//
//  Channel.swift
//  TuneInPlusApp
//
//  Created by Mohit Arora on 2024-04-26.
//

import Foundation

struct Channel: Hashable, Codable {
    let name: String
    let url: URL
    
    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
    
    // Define keys used in JSON
    enum CodingKeys: String, CodingKey {
        case name, url
    }
    
    // Implement custom decoder to handle JSON without an id
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let urlString = try container.decode(String.self, forKey: .url)
        guard let url = URL(string: urlString) else {
            throw DecodingError.dataCorruptedError(forKey: .url, in: container, debugDescription: "Invalid URL format")
        }
        
        self.init(name: name, url: url)
    }
}
