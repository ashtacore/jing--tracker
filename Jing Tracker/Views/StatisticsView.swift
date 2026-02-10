import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Query(sort: \WellnessEvent.date, order: .forward) private var events: [WellnessEvent]

    @State private var startDate: Date?
    @State private var endDate: Date = Date()
    @State private var selectedCalendarDate: Date?
    @State private var showingDayDetail = false

    var effectiveStartDate: Binding<Date> {
        Binding(
            get: { startDate ?? events.first?.date ?? Date()},
            set: { startDate = $0 }
        )
    }
    
    var inRangeEvents: [WellnessEvent] {
        events
            .filter { $0.date >= effectiveStartDate.wrappedValue && $0.date <= endDate }
            .sorted(by: { $0.date < $1.date })
    }
    
    var masturbationDates: [Date] {
        events
            .filter { $0.type == .masturbation }
            .map { $0.date }
    }
    
    var sexDates: [Date] {
        events
            .filter { $0.type == .sex }
            .map { $0.date }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    DateRangePicker(startDate: effectiveStartDate, endDate: $endDate)
                    
                    // Averages Section
                    VStack(spacing: 16) {
                        Text("Averages")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        AverageCard(
                            event: .masturbation,
                            events: inRangeEvents,
                            startDate: effectiveStartDate.wrappedValue,
                            endDate: endDate
                        )
                        
                        AverageCard(
                            event: .sex,
                            events: inRangeEvents,
                            startDate: effectiveStartDate.wrappedValue,
                            endDate: endDate
                        )
                    }
                    
                    // Trend Chart Section
                    TrendChart(
                        masturbationDates: masturbationDates,
                        sexDates: sexDates,
                        startDate: effectiveStartDate.wrappedValue,
                        endDate: endDate
                    )
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
        }
    }
}
