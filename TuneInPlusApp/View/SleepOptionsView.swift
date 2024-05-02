//
//  SleepOptionsView.swift
//  TuneInPlusApp
//
//  Created by Mohit Arora on 2024-05-02.
//

import SwiftUI

struct SleepOptionsView: View {
    @ObservedObject var viewModel = ChannelManager.shared

    var body: some View {
        NavigationView {
            List {
                ForEach(1...8, id: \.self) { index in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(index * 15) minutes")
                        }
                        Spacer()  // This pushes the text to the left and the checkmark to the right
                        if viewModel.selectedOption == index {
                            Image(systemName: "checkmark")  // System name for checkmark image
                                .foregroundColor(.blue)  // Color of the checkmark
                        }
                    }
                    .contentShape(Rectangle())  // Add this modifier
                    .shadow(color: Color("Shadow"), radius: 3, x: 0, y: 2)
                    .listRowBackground(viewModel.selectedOption == index ? Color("PlayingBackground").opacity(0.2) : Color("IdleBackground").opacity(0.5))
                    .onTapGesture {
                        // Toggle selection: deselect if already selected, otherwise select
                        if viewModel.selectedOption == index {
                            viewModel.selectedOption = nil
                        } else {
                            viewModel.selectedOption = index
                        }
                    }
                }
            }
            .padding(.top)
            .listStyle(.plain)
            .navigationTitle("Sleep Options")
            .background(Color("Background"))
        }
    }
}

#Preview {
    SleepOptionsView()
}
