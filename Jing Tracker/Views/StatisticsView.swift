import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Query(sort: \WellnessEvent.date, order: .forward) private var events: [WellnessEvent]

    var firstEventDate: Date {
        return events.first?.date ?? Date()
    }
    
    @State private var startDate: Date = firstEventDate
    @State private var endDate: Date = Date()
    @State private var selectedCalendarDate: Date?
    @State private var showingDayDetail = false

    var inRangeEvents: [WellnessEvent] {
        events
            .filter { $0.date >= startDate && $0.date <= endDate }
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
                    DateRangePicker(startDate: $startDate, endDate: $endDate)
                    
                    // Averages Section
                    VStack(spacing: 16) {
                        Text("Averages")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        AverageCard(
                            event: .Masturbation,
                            events: inRangeEvents,
                        )
                        
                        AverageCard(
                            event: .Sex,
                            events: inRangeEvents,
                        )
                    }
                    
                    // Trend Chart Section
                    TrendChart(
                        masturbationDates: $masturbationDates,
                        sexDates: $sexDates,
                        startDate: $startDate,
                        endDate: $endDate
                    )
                    
                    // Calendar Section
                    CalendarView(
                        masturbationDates: $masturbationDates,
                        sexDates: $sexDates,
                        onDateSelected: { date in
                            selectedCalendarDate = date
                            showingDayDetail = true
                        },
                    )
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
            .alert (
                selectedCalendarDate.map { "Selected Date: \($0,String(format: "yyyy-MM-dd"))" } ?? "",
                isPresented: $showingDayDetail,
                message: { Text("Details for the selected date") },
            )
            //.sheet(isPresented: $showingDayDetail) {
            //    if let selectedDate = selectedCalendarDate {
            //        DayInfoPopup(selectedDate: $selectedDate, events: $events)
            //    }
            //}
        }
    }
}
