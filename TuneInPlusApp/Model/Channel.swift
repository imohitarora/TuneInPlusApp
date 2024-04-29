//
//  Channel.swift
//  TuneInPlusApp
//
//  Created by Mohit Arora on 2024-04-26.
//

import Foundation

struct Channel: Identifiable, Hashable, Encodable, Decodable {
    var id = UUID()
    let name: String
    let url: URL
    var isFavorite = false
    
    init(name: String, url: URL, uuid: UUID = UUID(), isFavorite: Bool = false) {
        self.id = uuid
        self.name = name
        self.url = url
        self.isFavorite = isFavorite
    }
}
