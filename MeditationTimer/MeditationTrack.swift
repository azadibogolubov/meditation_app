//
//  MeditationTrack.swift
//  MeditationTimer
//
//  Created by Azadi Bogolubov on 7/24/26.
//


import Foundation

struct MeditationTrack: Identifiable {
    let id = UUID()
    let title: String
    let filename: String      // e.g. "morning-calm" — no extension
    let fileExtension: String // "m4a" or "mp3"
    let imageName: String     // matches the name in Assets.xcassets
}

let sampleTracks: [MeditationTrack] = [
    MeditationTrack(title: "Lofi Drones",     filename: "lofi_drones",    fileExtension: "mp3", imageName: ""),
    MeditationTrack(title: "Psychedelic Choir",     filename: "psychedelic_choir",    fileExtension: "mp3", imageName: "")
]
