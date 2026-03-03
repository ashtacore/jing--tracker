import Testing
import Foundation
@testable import Jing_Tracker

/// Tests for the statistics helper functions in `StatsHelper.swift`.
struct StatsHelperTests {

    // MARK: - Helpers

    /// Creates a `Date` for the given year-month-day at noon UTC.
    private func date(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12
        components.timeZone = TimeZone(identifier: "UTC")
        return Calendar.current.date(from: components)!
    }

    // MARK: - averageEventsPerWeek

    @Test("averageEventsPerWeek returns nil for empty dates")
    func weeklyAverageEmptyDates() {
        let result = averageEventsPerWeek(
            sortedDates: [],
            startDate: date(year: 2024, month: 1, day: 1),
            endDate: date(year: 2024, month: 2, day: 1)
        )
        #expect(result == nil)
    }

    @Test("averageEventsPerWeek returns nil when endDate <= startDate")
    func weeklyAverageInvalidRange() {
        let start = date(year: 2024, month: 2, day: 1)
        let end = date(year: 2024, month: 1, day: 1)
        let result = averageEventsPerWeek(
            sortedDates: [date(year: 2024, month: 1, day: 15)],
            startDate: start,
            endDate: end
        )
        #expect(result == nil)
    }

    @Test("averageEventsPerWeek returns nil for less than one complete week")
    func weeklyAverageNoCompleteWeek() {
        let start = date(year: 2024, month: 1, day: 1)
        let end = date(year: 2024, month: 1, day: 6) // only 5 days
        let result = averageEventsPerWeek(
            sortedDates: [date(year: 2024, month: 1, day: 3)],
            startDate: start,
            endDate: end
        )
        #expect(result == nil)
    }

    @Test("averageEventsPerWeek calculates correctly with known data")
    func weeklyAverageKnownData() {
        let start = date(year: 2024, month: 1, day: 1)
        let end = date(year: 2024, month: 1, day: 15) // 14 days = 2 complete weeks
        // 4 events across 2 weeks = 2.0 per week
        let dates = [
            date(year: 2024, month: 1, day: 2),
            date(year: 2024, month: 1, day: 4),
            date(year: 2024, month: 1, day: 9),
            date(year: 2024, month: 1, day: 12),
        ]
        let result = averageEventsPerWeek(sortedDates: dates, startDate: start, endDate: end)
        #expect(result == 2.0)
    }

    // MARK: - averageEventsPerMonth

    @Test("averageEventsPerMonth returns nil for empty dates")
    func monthlyAverageEmptyDates() {
        let result = averageEventsPerMonth(
            sortedDates: [],
            startDate: date(year: 2024, month: 1, day: 1),
            endDate: date(year: 2024, month: 3, day: 1)
        )
        #expect(result == nil)
    }

    @Test("averageEventsPerMonth returns nil when endDate <= startDate")
    func monthlyAverageInvalidRange() {
        let start = date(year: 2024, month: 3, day: 1)
        let end = date(year: 2024, month: 1, day: 1)
        let result = averageEventsPerMonth(
            sortedDates: [date(year: 2024, month: 2, day: 1)],
            startDate: start,
            endDate: end
        )
        #expect(result == nil)
    }

    @Test("averageEventsPerMonth returns nil for less than one complete month")
    func monthlyAverageNoCompleteMonth() {
        let start = date(year: 2024, month: 1, day: 1)
        let end = date(year: 2024, month: 1, day: 20) // less than a month
        let result = averageEventsPerMonth(
            sortedDates: [date(year: 2024, month: 1, day: 10)],
            startDate: start,
            endDate: end
        )
        #expect(result == nil)
    }

    @Test("averageEventsPerMonth calculates correctly with known data")
    func monthlyAverageKnownData() {
        let start = date(year: 2024, month: 1, day: 1)
        let end = date(year: 2024, month: 4, day: 1) // 3 complete months
        // 6 events across 3 months = 2.0 per month
        let dates = [
            date(year: 2024, month: 1, day: 5),
            date(year: 2024, month: 1, day: 20),
            date(year: 2024, month: 2, day: 10),
            date(year: 2024, month: 2, day: 25),
            date(year: 2024, month: 3, day: 3),
            date(year: 2024, month: 3, day: 15),
        ]
        let result = averageEventsPerMonth(sortedDates: dates, startDate: start, endDate: end)
        #expect(result == 2.0)
    }

    // MARK: - averageEventsPerYear

    @Test("averageEventsPerYear returns nil for empty dates")
    func yearlyAverageEmptyDates() {
        let result = averageEventsPerYear(
            sortedDates: [],
            startDate: date(year: 2023, month: 1, day: 1),
            endDate: date(year: 2025, month: 1, day: 1)
        )
        #expect(result == nil)
    }

    @Test("averageEventsPerYear returns nil when endDate <= startDate")
    func yearlyAverageInvalidRange() {
        let start = date(year: 2025, month: 1, day: 1)
        let end = date(year: 2023, month: 1, day: 1)
        let result = averageEventsPerYear(
            sortedDates: [date(year: 2024, month: 6, day: 1)],
            startDate: start,
            endDate: end
        )
        #expect(result == nil)
    }

    @Test("averageEventsPerYear returns nil for less than one complete year")
    func yearlyAverageNoCompleteYear() {
        let start = date(year: 2024, month: 1, day: 1)
        let end = date(year: 2024, month: 11, day: 1) // less than a year
        let result = averageEventsPerYear(
            sortedDates: [date(year: 2024, month: 6, day: 1)],
            startDate: start,
            endDate: end
        )
        #expect(result == nil)
    }

    @Test("averageEventsPerYear calculates correctly with known data")
    func yearlyAverageKnownData() {
        let start = date(year: 2023, month: 1, day: 1)
        let end = date(year: 2025, month: 1, day: 1) // 2 complete years
        // 10 events across 2 years = 5.0 per year
        let dates = [
            date(year: 2023, month: 2, day: 1),
            date(year: 2023, month: 4, day: 1),
            date(year: 2023, month: 6, day: 1),
            date(year: 2023, month: 8, day: 1),
            date(year: 2023, month: 10, day: 1),
            date(year: 2024, month: 1, day: 15),
            date(year: 2024, month: 3, day: 15),
            date(year: 2024, month: 5, day: 15),
            date(year: 2024, month: 7, day: 15),
            date(year: 2024, month: 9, day: 15),
        ]
        let result = averageEventsPerYear(sortedDates: dates, startDate: start, endDate: end)
        #expect(result == 5.0)
    }

    // MARK: - averagesPerWeek

    @Test("averagesPerWeek returns correct number of slices")
    func weeklySliceCount() {
        let start = date(year: 2024, month: 1, day: 1)
        let end = date(year: 2024, month: 1, day: 22) // 21 days = 3 complete weeks
        let dates = [
            date(year: 2024, month: 1, day: 3),
            date(year: 2024, month: 1, day: 10),
            date(year: 2024, month: 1, day: 17),
        ]
        let result = averagesPerWeek(sortedDates: dates, startDate: start, endDate: end)
        #expect(result?.count == 3)
    }

    @Test("averagesPerWeek returns nil for empty dates")
    func weeklySliceEmptyDates() {
        let result = averagesPerWeek(
            sortedDates: [],
            startDate: date(year: 2024, month: 1, day: 1),
            endDate: date(year: 2024, month: 2, day: 1)
        )
        #expect(result == nil)
    }

    @Test("averagesPerWeek calculates per-slice values correctly")
    func weeklySliceValues() {
        let start = date(year: 2024, month: 1, day: 1)
        let end = date(year: 2024, month: 1, day: 15) // 2 weeks
        let dates = [
            // Week 1: 3 events
            date(year: 2024, month: 1, day: 1),
            date(year: 2024, month: 1, day: 3),
            date(year: 2024, month: 1, day: 6),
            // Week 2: 1 event
            date(year: 2024, month: 1, day: 10),
        ]
        let result = averagesPerWeek(sortedDates: dates, startDate: start, endDate: end)
        #expect(result?[0].average == 3.0)
        #expect(result?[1].average == 1.0)
    }

    // MARK: - averagesPerMonth

    @Test("averagesPerMonth returns correct number of slices")
    func monthlySliceCount() {
        let start = date(year: 2024, month: 1, day: 1)
        let end = date(year: 2024, month: 4, day: 1) // 3 complete months
        let dates = [date(year: 2024, month: 2, day: 15)]
        let result = averagesPerMonth(sortedDates: dates, startDate: start, endDate: end)
        #expect(result?.count == 3)
    }

    @Test("averagesPerMonth returns nil for empty dates")
    func monthlySliceEmptyDates() {
        let result = averagesPerMonth(
            sortedDates: [],
            startDate: date(year: 2024, month: 1, day: 1),
            endDate: date(year: 2024, month: 4, day: 1)
        )
        #expect(result == nil)
    }

    @Test("averagesPerMonth calculates per-slice values correctly")
    func monthlySliceValues() {
        let start = date(year: 2024, month: 1, day: 1)
        let end = date(year: 2024, month: 3, day: 1) // 2 months
        let dates = [
            // Month 1: 2 events
            date(year: 2024, month: 1, day: 5),
            date(year: 2024, month: 1, day: 20),
            // Month 2: 0 events
        ]
        let result = averagesPerMonth(sortedDates: dates, startDate: start, endDate: end)
        #expect(result?[0].average == 2.0)
        #expect(result?[1].average == 0.0)
    }

    // MARK: - averagesPerYear

    @Test("averagesPerYear returns correct number of slices")
    func yearlySliceCount() {
        let start = date(year: 2022, month: 1, day: 1)
        let end = date(year: 2025, month: 1, day: 1) // 3 complete years
        let dates = [date(year: 2023, month: 6, day: 1)]
        let result = averagesPerYear(sortedDates: dates, startDate: start, endDate: end)
        #expect(result?.count == 3)
    }

    @Test("averagesPerYear returns nil for empty dates")
    func yearlySliceEmptyDates() {
        let result = averagesPerYear(
            sortedDates: [],
            startDate: date(year: 2022, month: 1, day: 1),
            endDate: date(year: 2025, month: 1, day: 1)
        )
        #expect(result == nil)
    }

    @Test("averagesPerYear calculates per-slice values correctly")
    func yearlySliceValues() {
        let start = date(year: 2023, month: 1, day: 1)
        let end = date(year: 2025, month: 1, day: 1) // 2 years
        let dates = [
            // Year 1: 3 events
            date(year: 2023, month: 3, day: 1),
            date(year: 2023, month: 6, day: 1),
            date(year: 2023, month: 9, day: 1),
            // Year 2: 1 event
            date(year: 2024, month: 5, day: 1),
        ]
        let result = averagesPerYear(sortedDates: dates, startDate: start, endDate: end)
        #expect(result?[0].average == 3.0)
        #expect(result?[1].average == 1.0)
    }
}
