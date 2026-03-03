import SwiftUI
import SwiftData

/// Generates reproducible mock `WellnessEvent` data for SwiftUI previews.
///
/// Usage in a `#Preview`:
/// ```swift
/// #Preview {
///     MyView()
///         .modelContainer(MockDataGenerator.makeContainer())
/// }
/// ```
@MainActor
final class MockDataGenerator {

    // MARK: - Public API

    /// Creates an in-memory `ModelContainer` pre-populated with random events.
    ///
    /// - Parameters:
    ///   - years: Number of years of history to generate (default 2).
    ///   - endDate: The most recent day to generate data for (default today).
    ///   - seed: Optional seed for deterministic output. Pass `nil` for random data each time.
    /// - Returns: A ready-to-use `ModelContainer` with mock data inserted.
    static func makeContainer(
        years: Int = 2,
        endDate: Date = .now,
        seed: UInt64? = 42
    ) -> ModelContainer {
        let schema = Schema([WellnessEvent.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        let container: ModelContainer
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("MockDataGenerator: Could not create ModelContainer – \(error)")
        }

        let context = container.mainContext

        var rng: any RandomNumberGenerator = seed.map { SeededRandomNumberGenerator(seed: $0) }
            ?? SystemRandomNumberGenerator()

        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .year, value: -years, to: endDate) else {
            return container
        }

        var currentDay = startDate
        while currentDay <= endDate {
            let eventTypes = eventsForDay(using: &rng)
            for eventType in eventTypes {
                let date = randomTime(on: currentDay, using: &rng)
                let event = WellnessEvent(type: eventType, date: date)
                context.insert(event)
            }
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDay) else { break }
            currentDay = nextDay
        }

        return container
    }

    // MARK: - Core Algorithm

    /// Determines which events (if any) happen on a single day.
    ///
    /// The algorithm rolls a number 0–10:
    /// - 0: `.masturbation` — stop
    /// - 1: `.sex` — stop
    /// - 2–4: nothing — stop
    /// - 5–8: nothing — re-roll
    /// - 9: `.sex` — re-roll
    /// - 10: `.masturbation` — re-roll
    ///
    /// Re-rolling can stack multiple events on a single day.
    ///
    /// - Parameters:
    ///   - rng: Any `RandomNumberGenerator` (pass a seeded one for determinism).
    ///   - maxIterations: Safety cap to prevent runaway loops (default 20).
    /// - Returns: An array of `EventType` values for the day (may be empty).
    static func eventsForDay(
        using rng: inout some RandomNumberGenerator,
        maxIterations: Int = 20
    ) -> [EventType] {
        var events: [EventType] = []
        var iterations = 0

        while iterations < maxIterations {
            iterations += 1
            let roll = Int.random(in: 0...10, using: &rng)

            switch roll {
            case 0:
                events.append(.masturbation)
                return events
            case 1:
                events.append(.sex)
                return events
            case 2...4:
                return events
            case 9:
                events.append(.sex)
                // re-roll
            case 10:
                events.append(.masturbation)
                // re-roll
            default:
                // 5–8: nothing, re-roll
                break
            }
        }

        return events
    }

    // MARK: - Helpers

    /// Returns a random `Date` on the given calendar day (random hour, minute, second).
    private static func randomTime(
        on day: Date,
        using rng: inout some RandomNumberGenerator
    ) -> Date {
        let calendar = Calendar.current
        let hour = Int.random(in: 0...23, using: &rng)
        let minute = Int.random(in: 0...59, using: &rng)
        let second = Int.random(in: 0...59, using: &rng)

        return calendar.date(
            bySettingHour: hour, minute: minute, second: second, of: day
        ) ?? day
    }
}
