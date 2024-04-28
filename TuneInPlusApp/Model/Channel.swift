//
//  Channel.swift
//  TuneInPlusApp
//
//  Created by Mohit Arora on 2024-04-26.
//

import Foundation

struct Channel: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let url: URL
}
