//
//  SearchBar.swift
//  TuneInPlusApp
//
//  Created by Mohit Arora on 2024-04-30.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $text)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color("IdleBackground").opacity(0.5))
        .cornerRadius(10.0)
    }
}

#Preview {
    SearchBar(text: .constant("mirchi"))
}
