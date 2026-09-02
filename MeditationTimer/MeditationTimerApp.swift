//
//  MeditationTimerApp.swift
//  MeditationTimer
//
//  Created by Azadi Bogolubov on 7/24/26.
//

import SwiftUI
import SwiftData

@main
struct MindfulTimerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: MeditationSession.self)
    }
}
