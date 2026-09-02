//
//  MeditationTimerTests.swift
//  MeditationTimerTests
//
//  Created by Azadi Bogolubov on 7/24/26.
//

import XCTest
import SwiftData
@testable import MeditationTimer

// MARK: - TimeFormatter

final class TimeFormatterTests: XCTestCase {

    // Happy path
    func test_wholeMinutes() {
        XCTAssertEqual(TimeFormatter.string(from: 300), "05:00")
    }

    func test_minutesAndSeconds() {
        XCTAssertEqual(TimeFormatter.string(from: 125), "02:05")
    }

    func test_zeroSeconds() {
        XCTAssertEqual(TimeFormatter.string(from: 0), "00:00")
    }

    // Adversarial
    func test_negativeSecondsClampsToZero() {
        XCTAssertEqual(TimeFormatter.string(from: -45), "00:00")
    }

    func test_veryLargeDurationDoesNotCrash() {
        XCTAssertEqual(TimeFormatter.string(from: 3_661), "61:01")
    }

    func test_intMaxDoesNotCrash() {
        XCTAssertNoThrow(TimeFormatter.string(from: Int.max))
    }
}

// MARK: - ProgressCalculator

final class ProgressCalculatorTests: XCTestCase {

    // Happy path
    func test_halfway() {
        XCTAssertEqual(ProgressCalculator.fraction(remaining: 150, totalMinutes: 5), 0.5, accuracy: 0.0001)
    }

    func test_atStart() {
        XCTAssertEqual(ProgressCalculator.fraction(remaining: 300, totalMinutes: 5), 1.0, accuracy: 0.0001)
    }

    func test_atEnd() {
        XCTAssertEqual(ProgressCalculator.fraction(remaining: 0, totalMinutes: 5), 0.0, accuracy: 0.0001)
    }

    // Adversarial
    func test_zeroMinutesDoesNotDivideByZero() {
        XCTAssertEqual(ProgressCalculator.fraction(remaining: 10, totalMinutes: 0), 0.0)
    }

    func test_remainingExceedsTotalClampsToOne() {
        XCTAssertEqual(ProgressCalculator.fraction(remaining: 9_999, totalMinutes: 5), 1.0, accuracy: 0.0001)
    }

    func test_negativeRemainingClampsToZero() {
        XCTAssertEqual(ProgressCalculator.fraction(remaining: -50, totalMinutes: 5), 0.0)
    }

    func test_negativeTotalMinutesDoesNotCrash() {
        XCTAssertNoThrow(ProgressCalculator.fraction(remaining: 10, totalMinutes: -5))
    }
}

// MARK: - TrackNavigator

final class TrackNavigatorTests: XCTestCase {

    // Happy path
    func test_advanceToNextTrack() {
        XCTAssertEqual(TrackNavigator.nextIndex(current: 0, delta: 1, trackCount: 3), 1)
    }

    func test_nextWrapsFromLastToFirst() {
        XCTAssertEqual(TrackNavigator.nextIndex(current: 2, delta: 1, trackCount: 3), 0)
    }

    func test_previousWrapsFromFirstToLast() {
        XCTAssertEqual(TrackNavigator.nextIndex(current: 0, delta: -1, trackCount: 3), 2)
    }

    // Adversarial
    func test_noCurrentTrackReturnsNil() {
        XCTAssertNil(TrackNavigator.nextIndex(current: nil, delta: 1, trackCount: 3))
    }

    func test_emptyTrackListReturnsNil() {
        XCTAssertNil(TrackNavigator.nextIndex(current: 0, delta: 1, trackCount: 0))
    }

    func test_singleTrackWrapsToItself() {
        XCTAssertEqual(TrackNavigator.nextIndex(current: 0, delta: 1, trackCount: 1), 0)
    }

    func test_largeDeltaWrapsCorrectly() {
        // Simulates rapid/spammed next-button taps summing to a delta larger than the list
        XCTAssertEqual(TrackNavigator.nextIndex(current: 0, delta: 7, trackCount: 3), 1)
    }

    func test_negativeDeltaLargerThanListWraps() {
        XCTAssertEqual(TrackNavigator.nextIndex(current: 0, delta: -7, trackCount: 3), 2)
    }
}

// MARK: - ThumbnailURLBuilder ("network outage" surface)
// These don't simulate a dropped connection directly (AsyncImage's networking isn't mockable
// without wrapping URLSession, which is a bigger refactor) — instead they cover the inputs that
// would otherwise trigger silent broken-image requests, which is the practical failure mode here.

final class ThumbnailURLBuilderTests: XCTestCase {

    // Happy path
    func test_validID() {
        XCTAssertEqual(
            ThumbnailURLBuilder.url(forYouTubeID: "dQw4w9WgXcQ")?.absoluteString,
            "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg"
        )
    }

    // Adversarial
    func test_emptyIDReturnsNilInsteadOfBrokenURL() {
        XCTAssertNil(ThumbnailURLBuilder.url(forYouTubeID: ""))
    }

    func test_whitespaceOnlyIDReturnsNil() {
        XCTAssertNil(ThumbnailURLBuilder.url(forYouTubeID: "   "))
    }

    func test_pathTraversalAttemptStaysOnExpectedHost() {
        // A malicious/malformed ID must never redirect the request to an unexpected host
        let url = ThumbnailURLBuilder.url(forYouTubeID: "../../evil.com")
        XCTAssertEqual(url?.host, "img.youtube.com")
    }

    func test_veryLongIDDoesNotCrash() {
        let longID = String(repeating: "a", count: 10_000)
        XCTAssertNoThrow(ThumbnailURLBuilder.url(forYouTubeID: longID))
    }
}

// MARK: - MeditationSession (SwiftData)

final class MeditationSessionTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        // In-memory container: no disk I/O, no shared state between tests, no network involved.
        let schema = Schema([MeditationSession.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
    }

    // Happy path
    func test_insertAndFetchSession() throws {
        let session = MeditationSession(durationMinutes: 10, trackTitle: "Morning Calm")
        context.insert(session)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<MeditationSession>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.durationMinutes, 10)
        XCTAssertEqual(fetched.first?.trackTitle, "Morning Calm")
    }

    // Adversarial
    func test_sessionWithNoTrackDefaultsToNilNotCrash() throws {
        let session = MeditationSession(durationMinutes: 5)
        context.insert(session)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<MeditationSession>())
        XCTAssertNil(fetched.first?.trackTitle)
    }

    func test_zeroDurationSessionStillSaves() throws {
        let session = MeditationSession(durationMinutes: 0)
        context.insert(session)
        XCTAssertNoThrow(try context.save())
    }

    func test_negativeDurationDoesNotCrashOnSave() throws {
        // Guards against a future bug upstream ever passing a negative value through
        let session = MeditationSession(durationMinutes: -5)
        context.insert(session)
        XCTAssertNoThrow(try context.save())
    }

    func test_veryLongTrackTitleSaves() throws {
        let longTitle = String(repeating: "x", count: 5_000)
        let session = MeditationSession(durationMinutes: 5, trackTitle: longTitle)
        context.insert(session)
        XCTAssertNoThrow(try context.save())
    }
}
