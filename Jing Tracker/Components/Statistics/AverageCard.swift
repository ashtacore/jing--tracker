import SwiftUI

struct AverageCard: View {
    var event: EventType
    var events: [WellnessEvent]
    var startDate: Date
    var endDate: Date
    
    var eventDates: [Date] {
        events
            .filter { $0.type == event }
            .map { $0.date }
    }

    var weeklyAvg: Double? {
        averageEventsPerWeek(sortedDates: eventDates, startDate: startDate, endDate: endDate)
    }
    
    var monthlyAvg: Double? {
        averageEventsPerMonth(sortedDates: eventDates, startDate: startDate, endDate: endDate)
    }
    
    var yearlyAvg: Double? {
        averageEventsPerYear(sortedDates: eventDates, startDate: startDate, endDate: endDate)
    }

    private func averageItem(label: String, value: Double?) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let value = value {
                Text(String(format: "%.1f", value))
                    .font(.title3)
                    .fontWeight(.semibold)
            } else {
                Text("Not enough data")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: event.icon)
                    .foregroundStyle(event.color)
                    .font(.title2)
                Text(event.rawValue.capitalized + " Averages")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 12) {
                averageItem(label: "Per Week", value: weeklyAvg)
                Divider()
                    .frame(height: 40)
                averageItem(label: "Per Month", value: monthlyAvg)
                Divider()
                    .frame(height: 40)
                averageItem(label: "Per Year", value: yearlyAvg)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}
