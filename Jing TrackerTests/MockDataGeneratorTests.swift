import Testing
import Foundation
import SwiftData
@testable import Jing_Tracker

/// Tests for the core `eventsForDay` algorithm in `MockDataGenerator`.
struct MockDataGeneratorTests {

    // MARK: - Single-roll outcomes (rolls 0–4 never re-roll)

    /// A helper RNG that returns a fixed sequence of values.
    /// Each call to `next()` returns the next UInt64 in the list, cycling if needed.
    struct FixedRNG: RandomNumberGenerator {
        var values: [UInt64]
        var index = 0

        mutating func next() -> UInt64 {
            let value = values[index % values.count]
            index += 1
            return value
        }
    }

    // To control `Int.random(in: 0...10, using:)` we need to understand that
    // Swift uses the RNG's UInt64 output to uniformly select a value in the range.
    // Rather than reverse-engineering the internal mapping, we test properties
    // using a seeded RNG and verify statistical/behavioral invariants.

    // MARK: - Determinism

    @Test("Same seed produces identical output")
    func sameSeedProducesIdenticalOutput() {
        var rng1 = SeededRandomNumberGenerator(seed: 123)
        var rng2 = SeededRandomNumberGenerator(seed: 123)

        let events1 = MockDataGenerator.eventsForDay(using: &rng1)
        let events2 = MockDataGenerator.eventsForDay(using: &rng2)

        #expect(events1 == events2)
    }

    @Test("Different seeds produce different output over many days")
    func differentSeedsProduceDifferentOutput() {
        var rng1 = SeededRandomNumberGenerator(seed: 1)
        var rng2 = SeededRandomNumberGenerator(seed: 999)

        var allSame = true
        for _ in 0..<100 {
            let e1 = MockDataGenerator.eventsForDay(using: &rng1)
            let e2 = MockDataGenerator.eventsForDay(using: &rng2)
            if e1 != e2 {
                allSame = false
                break
            }
        }
        #expect(!allSame, "100 days with different seeds should not all be identical")
    }

    // MARK: - maxIterations cap

    @Test("maxIterations caps the number of events")
    func maxIterationsCapsEvents() {
        var rng = SeededRandomNumberGenerator(seed: 42)

        // Even with many re-rolls, we should never exceed maxIterations events
        for _ in 0..<200 {
            let events = MockDataGenerator.eventsForDay(using: &rng, maxIterations: 5)
            #expect(events.count <= 5)
        }
    }

    @Test("maxIterations of 1 produces at most 1 event")
    func maxIterationsOfOneProducesAtMostOneEvent() {
        var rng = SeededRandomNumberGenerator(seed: 77)

        for _ in 0..<200 {
            let events = MockDataGenerator.eventsForDay(using: &rng, maxIterations: 1)
            #expect(events.count <= 1)
        }
    }

    // MARK: - Event type distribution

    @Test("Both event types appear over a large sample")
    func bothEventTypesAppear() {
        var rng = SeededRandomNumberGenerator(seed: 42)

        var hasMasturbation = false
        var hasSex = false

        for _ in 0..<1000 {
            let events = MockDataGenerator.eventsForDay(using: &rng)
            if events.contains(.masturbation) { hasMasturbation = true }
            if events.contains(.sex) { hasSex = true }
            if hasMasturbation && hasSex { break }
        }

        #expect(hasMasturbation, "Masturbation events should appear in 1000 days")
        #expect(hasSex, "Sex events should appear in 1000 days")
    }

    @Test("Empty days occur over a large sample")
    func emptyDaysOccur() {
        var rng = SeededRandomNumberGenerator(seed: 42)

        var hasEmpty = false
        for _ in 0..<1000 {
            let events = MockDataGenerator.eventsForDay(using: &rng)
            if events.isEmpty {
                hasEmpty = true
                break
            }
        }

        #expect(hasEmpty, "Some days should have no events")
    }

    @Test("Multi-event days occur over a large sample")
    func multiEventDaysOccur() {
        var rng = SeededRandomNumberGenerator(seed: 42)

        var hasMultiple = false
        for _ in 0..<1000 {
            let events = MockDataGenerator.eventsForDay(using: &rng)
            if events.count > 1 {
                hasMultiple = true
                break
            }
        }

        #expect(hasMultiple, "Some days should have multiple events from re-rolls")
    }

    @Test("Mixed event types on a single day occur over a large sample")
    func mixedEventDaysOccur() {
        var rng = SeededRandomNumberGenerator(seed: 42)

        var hasMixed = false
        for _ in 0..<2000 {
            let events = MockDataGenerator.eventsForDay(using: &rng)
            let hasBoth = events.contains(.masturbation) && events.contains(.sex)
            if hasBoth {
                hasMixed = true
                break
            }
        }

        #expect(hasMixed, "Some days should have both event types")
    }

    // MARK: - makeContainer

    @Test("makeContainer produces a non-empty dataset")
    @MainActor func makeContainerProducesData() throws {
        let container = MockDataGenerator.makeContainer(years: 1, seed: 42)
        let context = container.mainContext

        let descriptor = FetchDescriptor<WellnessEvent>()
        let events = try context.fetch(descriptor)

        #expect(!events.isEmpty, "1 year of mock data should produce events")
        // With ~365 days and the algorithm, we expect a meaningful number of events
        #expect(events.count > 50, "Expected more than 50 events in a year of data")
    }

    @Test("makeContainer with same seed is deterministic")
    @MainActor func makeContainerIsDeterministic() throws {
        let container1 = MockDataGenerator.makeContainer(years: 1, seed: 99)
        let container2 = MockDataGenerator.makeContainer(years: 1, seed: 99)

        var descriptor = FetchDescriptor<WellnessEvent>()
        descriptor.sortBy = [SortDescriptor(\WellnessEvent.date)]
        let events1 = try container1.mainContext.fetch(descriptor)
        let events2 = try container2.mainContext.fetch(descriptor)

        #expect(events1.count == events2.count, "Same seed should produce same event count")

        // Verify dates and types match
        for (e1, e2) in zip(events1, events2) {
            #expect(e1.type == e2.type)
            #expect(e1.date == e2.date)
        }
    }
}
