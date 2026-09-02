//
//  RootView.swift
//  MeditationTimer
//
//  Created by Azadi Bogolubov on 7/24/26.
//


import SwiftUI

struct RootView: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var lastTrack: MeditationTrack?

    private var currentTrackTitle: String? { audioManager.currentTrack?.title }

    var body: some View {
        TabView {
            timerTab
            resourcesTab
        }
    }

    var timerTab: some View {
        ScrollView {
            VStack(spacing: 24) {
                ContentView(
                    currentTrackTitle: currentTrackTitle,
                    isTrackPlaying: audioManager.isPlaying,
                    onTimerComplete: { audioManager.stop() },
                    onRestart: {
                        if let track = lastTrack { audioManager.play(track: track) }
                    },
                    onTrackPause: {
                        audioManager.isPlaying ? audioManager.pause() : audioManager.resume()
                    },
                    onTrackStop: { audioManager.stop() }
                )

                Divider()

                TrackListView(onSelectTrack: { track in
                    lastTrack = track
                    audioManager.play(track: track)
                })
            }
        }
        .tabItem { Label("Timer", systemImage: "timer") }
    }
    
    var resourcesTab: some View {
        ResourcesView()
            .tabItem { Label("Resources", systemImage: "link") }
    }
}
