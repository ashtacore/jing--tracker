import Foundation

// These functions return a double which represents the average number of events per week, month, or year,
// considering only complete weeks, months, or years from the first event date to the endDate provided.
func averageEventsPerWeek(sortedDates: [Date], endDate: Date) -> Double? {
    guard !sortedDates.isEmpty else { return nil }
    
    let firstDate = sortedDates[0]
    
    // Ensure endDate is after firstDate
    guard endDate > firstDate else { return nil }
    
    let calendar = Calendar.current
    
    // Calculate the number of complete weeks from first date to end date
    let components = calendar.dateComponents([.day], from: firstDate, to: endDate)
    guard let totalDays = components.day else { return nil }
    
    // Number of complete weeks (7 days = 1 week)
    let completeWeeks = totalDays / 7
    
    guard completeWeeks > 0 else { return nil }
    
    // Only count events up to the last complete week boundary
    let lastCompleteWeekEnd = calendar.date(byAdding: .day, value: completeWeeks * 7, to: firstDate)!
    
    // Count events within the complete weeks
    let eventsInCompleteWeeks = sortedDates.filter { $0 < lastCompleteWeekEnd }.count
    
    // Calculate average
    let averagePerWeek = Double(eventsInCompleteWeeks) / Double(completeWeeks)
    
    return averagePerWeek
}

func averageEventsPerMonth(sortedDates: [Date], endDate: Date) -> Double? {
    guard !sortedDates.isEmpty else { return nil }
    
    let firstDate = sortedDates[0]
    guard endDate > firstDate else { return nil }
    
    let calendar = Calendar.current
    
    // Get the number of complete months
    let components = calendar.dateComponents([.month], from: firstDate, to: endDate)
    guard let completeMonths = components.month, completeMonths > 0 else { return nil }
    
    // Calculate the boundary of the last complete month
    let lastCompleteMonthEnd = calendar.date(byAdding: .month, value: completeMonths, to: firstDate)!
    
    // Count events within complete months
    let eventsInCompleteMonths = sortedDates.filter { $0 < lastCompleteMonthEnd }.count
    
    return Double(eventsInCompleteMonths) / Double(completeMonths)
}

func averageEventsPerYear(sortedDates: [Date], endDate: Date) -> Double? {
    guard !sortedDates.isEmpty else { return nil }
    
    let firstDate = sortedDates[0]
    guard endDate > firstDate else { return nil }
    
    let calendar = Calendar.current
    
    // Get the number of complete years
    let components = calendar.dateComponents([.year], from: firstDate, to: endDate)
    guard let completeYears = components.year, completeYears > 0 else { return nil }
    
    // Calculate the boundary of the last complete year
    let lastCompleteYearEnd = calendar.date(byAdding: .year, value: completeYears, to: firstDate)!
    
    // Count events within complete years
    let eventsInCompleteYears = sortedDates.filter { $0 < lastCompleteYearEnd }.count
    
    return Double(eventsInCompleteYears) / Double(completeYears)
}


// These functions return an array of tuples containing the average number of events and the start date
// for each complete week, month, or year from the first event date to the endDate provided.
// These functions are useful for generating trend data over time.
func averagesPerWeek(sortedDates: [Date], endDate: Date) -> [(average: Double, startDate: Date)]? {
    guard !sortedDates.isEmpty else { return nil }
    
    let firstDate = sortedDates[0]
    guard endDate > firstDate else { return nil }
    
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day], from: firstDate, to: endDate)
    guard let totalDays = components.day else { return nil }
    
    let completeWeeks = totalDays / 7
    guard completeWeeks > 0 else { return nil }
    
    var results: [(Double, Date)] = []
    
    // For each complete week, count events
    for weekIndex in 0..<completeWeeks {
        let weekStart = calendar.date(byAdding: .day, value: weekIndex * 7, to: firstDate)!
        let weekEnd = calendar.date(byAdding: .day, value: (weekIndex + 1) * 7, to: firstDate)!
        
        let eventsInWeek = sortedDates.filter { $0 >= weekStart && $0 < weekEnd }.count
        results.append((Double(eventsInWeek), weekStart))
    }
    
    return results
}

func averagesPerMonth(sortedDates: [Date], endDate: Date) -> [(average: Double, startDate: Date)]? {
    guard !sortedDates.isEmpty else { return nil }
    
    let firstDate = sortedDates[0]
    guard endDate > firstDate else { return nil }
    
    let calendar = Calendar.current
    let components = calendar.dateComponents([.month], from: firstDate, to: endDate)
    guard let completeMonths = components.month, completeMonths > 0 else { return nil }
    
    var results: [(Double, Date)] = []
    
    // For each complete month, count events
    for monthIndex in 0..<completeMonths {
        let monthStart = calendar.date(byAdding: .month, value: monthIndex, to: firstDate)!
        let monthEnd = calendar.date(byAdding: .month, value: monthIndex + 1, to: firstDate)!
        
        let eventsInMonth = sortedDates.filter { $0 >= monthStart && $0 < monthEnd }.count
        results.append((Double(eventsInMonth), monthStart))
    }
    
    return results
}

func averagesPerYear(sortedDates: [Date], endDate: Date) -> [(average: Double, startDate: Date)]? {
    guard !sortedDates.isEmpty else { return nil }
    
    let firstDate = sortedDates[0]
    guard endDate > firstDate else { return nil }
    
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year], from: firstDate, to: endDate)
    guard let completeYears = components.year, completeYears > 0 else { return nil }
    
    var results: [(Double, Date)] = []
    
    // For each complete year, count events
    for yearIndex in 0..<completeYears {
        let yearStart = calendar.date(byAdding: .year, value: yearIndex, to: firstDate)!
        let yearEnd = calendar.date(byAdding: .year, value: yearIndex + 1, to: firstDate)!
        
        let eventsInYear = sortedDates.filter { $0 >= yearStart && $0 < yearEnd }.count
        results.append((Double(eventsInYear), yearStart))
    }
    
    return results
}
