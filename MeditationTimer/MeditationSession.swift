//
//  MeditationSession.swift
//  MeditationTimer
//
//  Created by Azadi Bogolubov on 7/24/26.
//


import Foundation
import SwiftData

@Model
class MeditationSession {
    var date: Date
    var durationMinutes: Int
    var trackTitle: String?

    init(date: Date = .now, durationMinutes: Int, trackTitle: String? = nil) {
        self.date = date
        self.durationMinutes = durationMinutes
        self.trackTitle = trackTitle
    }
}
