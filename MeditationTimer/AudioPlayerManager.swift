//
//  AudioPlayerManager.swift
//  MeditationTimer
//
//  Created by Azadi Bogolubov on 8/2/26.
//


import Foundation
import AVFoundation
import Combine

class AudioPlayerManager: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentTrack: MeditationTrack?

    private var player: AVAudioPlayer?

    init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession setup failed: \(error)")
        }
    }

    func play(track: MeditationTrack) {
        guard let url = Bundle.main.url(
            forResource: track.filename,
            withExtension: track.fileExtension
        ) else {
            print("Audio file not found: \(track.filename).\(track.fileExtension)")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1  // loop indefinitely
            player?.play()
            currentTrack = track
            isPlaying = true
        } catch {
            print("Playback failed: \(error)")
        }
    }

    func stop() {
        player?.stop()
        player = nil
        currentTrack = nil
        isPlaying = false
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func resume() {
        player?.play()
        isPlaying = true
    }
}
