import SwiftUI
import SwiftData
import AudioToolbox
import Combine

struct ContentView: View {
    let currentTrackTitle: String?
    
    let onTimerComplete: () -> Void
    let onRestart: () -> Void
    let onTrackPause: () -> Void
    let onTrackStop: () -> Void
    let isTrackPlaying: Bool
    
    init(currentTrackTitle: String? = nil,
         isTrackPlaying: Bool = false,
         onTimerComplete: @escaping () -> Void = {},
         onRestart: @escaping () -> Void = {},
         onTrackPause: @escaping () -> Void = {},
         onTrackStop: @escaping () -> Void = {}
    ) {
        self.currentTrackTitle = currentTrackTitle
        self.onTimerComplete = onTimerComplete
        self.onRestart = onRestart
        self.onTrackPause = onTrackPause
        self.onTrackStop = onTrackStop
        self.isTrackPlaying = isTrackPlaying
    }
    
    @State private var selectedMinutes: Int = 1
    @State private var secondsRemaining: Int = 1 * 60
    @State private var isRunning: Bool = false
    let minuteOptions = [1,3, 5, 10, 15, 20]

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MeditationSession.date, order: .reverse) private var pastSessions: [MeditationSession]

    var body: some View {
        VStack(spacing: 24) {
            Text("Meditation")
                .font(.title)
                .bold()

            Picker("Minutes", selection: $selectedMinutes) {
                ForEach(minuteOptions, id: \.self) { minutes in
                    Text("\(minutes) min").tag(minutes)
                }
            }
            .pickerStyle(.segmented)
            .disabled(isRunning)
            .onChange(of: selectedMinutes) {
                secondsRemaining = selectedMinutes * 60
            }

            ZStack {
                Circle()
                    .stroke(lineWidth: 12)
                    .opacity(0.15)

                Circle()
                    .trim(from: 0, to: progressFraction)
                    .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progressFraction)

                Text(TimeFormatter.string(from: secondsRemaining))
                    .font(.system(size: 44, weight: .thin, design: .rounded))
                    .monospacedDigit()
            }
            .frame(width: 220, height: 220)
            
            HStack(spacing: 12) {
                Button(secondsRemaining == 0 ? "Restart" : (isRunning ? "Pause" : "Start")) {
                    if secondsRemaining == 0 {
                        secondsRemaining = selectedMinutes * 60
                        onRestart()
                    }
                    isRunning.toggle()
                }
                .buttonStyle(.borderedProminent)

                if currentTrackTitle != nil {
                    Button(action: onTrackPause) {
                        Image(systemName: isTrackPlaying ? "pause.fill" : "play.fill")
                    }
                    .buttonStyle(.bordered)

                    Button(action: onTrackStop) {
                        Image(systemName: "stop.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            
            if !pastSessions.isEmpty {
                List {
                    Section("History") {
                        ForEach(pastSessions) { session in
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text("\(session.durationMinutes) min")
                                    Spacer()
                                    Text(session.date.formatted(date: .abbreviated, time: .shortened))
                                        .foregroundStyle(.secondary)
                                }
                                if let track = session.trackTitle {
                                    Text(track)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 240)
            }
        }
        .padding()
        .onReceive(timer) { _ in
            guard isRunning, secondsRemaining > 0 else { return }
            secondsRemaining -= 1
            if secondsRemaining == 0 {
                isRunning = false
                AudioServicesPlaySystemSound(1005)
                modelContext.insert(
                    MeditationSession(durationMinutes: selectedMinutes, trackTitle: currentTrackTitle)
                )
                onTimerComplete()
            }
        }
    }

    var progressFraction: Double {
        ProgressCalculator.fraction(remaining: secondsRemaining, totalMinutes: selectedMinutes)
    }

    func timeString(from seconds: Int) -> String {
        TimeFormatter.string(from: seconds)
    }
}

#Preview {
    ContentView()
}
