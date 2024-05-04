//
//  Channel.swift
//  TuneInPlusApp
//
//  Created by Mohit Arora on 2024-04-26.
//

import Foundation

import Foundation

struct Channel: Hashable, Codable {
    let id: String
    let name: String
    let url: URL
    let country: String
    let meta: String?
    
    init(id: String, name: String, url: URL, country: String, meta: String) {
        self.id = id
        self.name = name
        self.url = url
        self.country = country
        self.meta = meta
    }
    
    // Define keys used in JSON
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case url
        case country
        case meta
    }
    
    // Implement custom decoder to handle JSON without an id
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let urlString = try container.decode(String.self, forKey: .url)
        let country = try container.decode(String.self, forKey: .country)
        let meta = try container.decodeIfPresent(String.self, forKey: .meta)
        guard let url = URL(string: urlString) else {
            throw DecodingError.dataCorruptedError(forKey: .url, in: container, debugDescription: "Invalid URL format")
        }
        
        self.init(id: id, name: name, url: url, country: country, meta: meta ?? "")
    }
}
