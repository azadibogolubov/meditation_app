//
//  MeditationLogic.swift
//  MeditationTimer
//
//  Created by Azadi Bogolubov on 8/1/26.
//

import Foundation

enum TimeFormatter {
    /// Formats a countdown as MM:SS. Negative input clamps to 00:00 rather than crashing or showing a negative time.
    static func string(from totalSeconds: Int) -> String {
        let safeSeconds = max(0, totalSeconds)
        let minutes = safeSeconds / 60
        let seconds = safeSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

enum ProgressCalculator {
    /// Fraction of the ring to fill. Guards against divide-by-zero (0-minute session) and clamps
    /// out-of-range `remaining` values instead of producing >1.0 or negative progress.
    static func fraction(remaining: Int, totalMinutes: Int) -> Double {
        let total = Double(totalMinutes * 60)
        guard total > 0 else { return 0 }
        let clampedRemaining = max(0, min(remaining, Int(total)))
        return Double(clampedRemaining) / total
    }
}

enum TrackNavigator {
    /// Computes the next track index, wrapping around in either direction.
    /// Returns nil if nothing is currently playing or the track list is empty.
    static func nextIndex(current: Int?, delta: Int, trackCount: Int) -> Int? {
        guard trackCount > 0, let current else { return nil }
        return ((current + delta) % trackCount + trackCount) % trackCount
    }
}
