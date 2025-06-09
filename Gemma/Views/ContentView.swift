//
//  ContentView.swift
//  Gemma
//
//  Created by Andre jones on 4/4/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: String = "start interview"
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                SessionHistoryWelcomeView()
                    .tabItem {
                        Label("History", systemImage: "book")
                    }.tag("first")
                StartInterviewWelcomeView()
                    .tabItem {
                        Label("Start Interview", systemImage: "play")
                    }.tag("start interview")
                CarlsListView(showHints: .constant(true))
                    .tabItem {
                        Label("Carl Logs", systemImage: "bubble.and.pencil")
                    }.tag("third")
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
