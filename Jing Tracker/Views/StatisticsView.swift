import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Query(sort: \WellnessEvent.date, order: .forward) private var events: [WellnessEvent]

    var firstEventDate: Date {
        let allDates = recentEvents.map { $0.date }
        return allDates.last ?? Date()
    }
    
    @State private var startDate: Date = firstEventDate
    @State private var endDate: Date = Date()

    var events: [WellnessEvent] {
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
                        
                        averageCard(
                            event: .Masturbation,
                            events: events,
                        )
                        
                        averageCard(
                            event: .Sex,
                            events: events,
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
                    calendarSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
            .sheet(isPresented: $showingDayDetail) {
                if let selectedDate = selectedCalendarDate {
                    dayDetailSheet(for: selectedDate)
                }
            }
        }
    }
    
    // MARK: - Calendar Section
    
    private func monthView(for month: Date) -> some View {
        let calendar = Calendar.current
        let monthFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter
        }()
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)!.count
        let firstWeekday = calendar.component(.weekday, from: month)
        let offsetDays = firstWeekday - calendar.firstWeekday
        let adjustedOffset = offsetDays < 0 ? offsetDays + 7 : offsetDays
        
        return VStack(alignment: .leading, spacing: 8) {
            Text(monthFormatter.string(from: month))
                .font(.subheadline)
                .fontWeight(.semibold)
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day.prefix(2))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Days grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                // Empty cells for offset
                ForEach(0..<adjustedOffset, id: \.self) { _ in
                    Color.clear
                        .frame(height: 32)
                }
                
                // Day cells
                ForEach(1...daysInMonth, id: \.self) { day in
                    let date = calendar.date(from: DateComponents(
                        year: calendar.component(.year, from: month),
                        month: calendar.component(.month, from: month),
                        day: day
                    ))!
                    
                    dayCell(for: date, day: day)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func dayCell(for date: Date, day: Int) -> some View {
        let isInRange = date >= startDate && date <= endDate
        let dayColor = isInRange ? colorForDay(date) : nil
        let hasEvents = dayColor != nil
        
        return Button {
            if isInRange {
                selectedCalendarDate = date
                showingDayDetail = true
            }
        } label: {
            ZStack {
                if let color = dayColor {
                    Circle()
                        .fill(color.opacity(0.8))
                }
                
                Text("\(day)")
                    .font(.caption)
                    .fontWeight(hasEvents ? .semibold : .regular)
                    .foregroundStyle(hasEvents ? .white : (isInRange ? .primary : .tertiary))
            }
            .frame(height: 32)
        }
        .buttonStyle(.plain)
        .disabled(!isInRange)
    }
    
    private func dayDetailSheet(for date: Date) -> some View {
        let events = eventsForDay(date)
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            return formatter
        }()
        
        return NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundStyle(.blue)
                            .font(.title2)
                        Text("Masturbation")
                            .font(.headline)
                        Spacer()
                        Text("\(events.masturbation)")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                            .font(.title2)
                        Text("Sex")
                            .font(.headline)
                        Spacer()
                        Text("\(events.sex)")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle(dateFormatter.string(from: date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingDayDetail = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
