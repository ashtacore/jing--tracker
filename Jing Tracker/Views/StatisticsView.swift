import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Query(sort: \WellnessEvent.date, order: .forward) private var events: [WellnessEvent]
    
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var hasInitialized: Bool = false
    
    enum TimePeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    @State private var selectedPeriod: TimePeriod = .week
    @State private var selectedCalendarDate: Date? = nil
    @State private var showingDayDetail: Bool = false
    
    // Filtered and sorted dates within the selected range
    var masturbationDates: [Date] {
        events
            .filter { $0.type == .masturbation && $0.date >= startDate && $0.date <= endDate }
            .map { $0.date }
            .sorted()
    }
    
    var sexDates: [Date] {
        events
            .filter { $0.type == .sex && $0.date >= startDate && $0.date <= endDate }
            .map { $0.date }
            .sorted()
    }
    
    // Calculate averages using StatsHelper functions
    var masturbationWeeklyAvg: Double? {
        averageEventsPerWeek(sortedDates: masturbationDates, endDate: endDate)
    }
    
    var masturbationMonthlyAvg: Double? {
        averageEventsPerMonth(sortedDates: masturbationDates, endDate: endDate)
    }
    
    var masturbationYearlyAvg: Double? {
        averageEventsPerYear(sortedDates: masturbationDates, endDate: endDate)
    }
    
    var sexWeeklyAvg: Double? {
        averageEventsPerWeek(sortedDates: sexDates, endDate: endDate)
    }
    
    var sexMonthlyAvg: Double? {
        averageEventsPerMonth(sortedDates: sexDates, endDate: endDate)
    }
    
    var sexYearlyAvg: Double? {
        averageEventsPerYear(sortedDates: sexDates, endDate: endDate)
    }
    
    // Chart data for trends
    var masturbationTrendData: [(average: Double, startDate: Date)]? {
        switch selectedPeriod {
        case .week:
            return averagesPerWeek(sortedDates: masturbationDates, endDate: endDate)
        case .month:
            return averagesPerMonth(sortedDates: masturbationDates, endDate: endDate)
        case .year:
            return averagesPerYear(sortedDates: masturbationDates, endDate: endDate)
        }
    }
    
    var sexTrendData: [(average: Double, startDate: Date)]? {
        switch selectedPeriod {
        case .week:
            return averagesPerWeek(sortedDates: sexDates, endDate: endDate)
        case .month:
            return averagesPerMonth(sortedDates: sexDates, endDate: endDate)
        case .year:
            return averagesPerYear(sortedDates: sexDates, endDate: endDate)
        }
    }
    
    // Calendar helper computed properties
    var allMonthsInRange: [Date] {
        let calendar = Calendar.current
        var months: [Date] = []
        var current = calendar.date(from: calendar.dateComponents([.year, .month], from: startDate))!
        let endMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: endDate))!
        
        while current <= endMonth {
            months.append(current)
            current = calendar.date(byAdding: .month, value: 1, to: current)!
        }
        return months
    }
    
    func eventsForDay(_ date: Date) -> (masturbation: Int, sex: Int) {
        let calendar = Calendar.current
        let masturbationCount = masturbationDates.filter { calendar.isDate($0, inSameDayAs: date) }.count
        let sexCount = sexDates.filter { calendar.isDate($0, inSameDayAs: date) }.count
        return (masturbationCount, sexCount)
    }
    
    func colorForDay(_ date: Date) -> Color? {
        let events = eventsForDay(date)
        if events.masturbation > 0 && events.sex > 0 {
            return .purple
        } else if events.masturbation > 0 {
            return .blue
        } else if events.sex > 0 {
            return .red
        }
        return nil
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Date Range Pickers
                    dateRangeSection
                    
                    // Averages Section
                    averagesSection
                    
                    // Trend Chart Section
                    trendChartSection
                    
                    // Calendar Section
                    calendarSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
            .onAppear {
                initializeDates()
            }
            .onChange(of: events) { _, _ in
                if !hasInitialized {
                    initializeDates()
                }
            }
            .sheet(isPresented: $showingDayDetail) {
                if let selectedDate = selectedCalendarDate {
                    dayDetailSheet(for: selectedDate)
                }
            }
        }
    }
    
    // MARK: - Date Range Section
    private var dateRangeSection: some View {
        VStack(spacing: 12) {
            Text("Date Range")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start Date")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    DatePicker("", selection: $startDate, in: ...endDate, displayedComponents: .date)
                        .labelsHidden()
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("End Date")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                        .labelsHidden()
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
    }
    
    // MARK: - Averages Section
    private var averagesSection: some View {
        VStack(spacing: 16) {
            Text("Averages")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            // Masturbation Averages
            averageCard(
                title: "Masturbation",
                icon: "hand.raised.fill",
                color: .blue,
                weeklyAvg: masturbationWeeklyAvg,
                monthlyAvg: masturbationMonthlyAvg,
                yearlyAvg: masturbationYearlyAvg
            )
            
            // Sex Averages
            averageCard(
                title: "Sex",
                icon: "heart.fill",
                color: .pink,
                weeklyAvg: sexWeeklyAvg,
                monthlyAvg: sexMonthlyAvg,
                yearlyAvg: sexYearlyAvg
            )
        }
    }
    
    private func averageCard(
        title: String,
        icon: String,
        color: Color,
        weeklyAvg: Double?,
        monthlyAvg: Double?,
        yearlyAvg: Double?
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title2)
                Text(title)
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
    
    // MARK: - Trend Chart Section
    private var trendChartSection: some View {
        VStack(spacing: 16) {
            Text("Trends Over Time")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            Picker("Time Period", selection: $selectedPeriod) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            trendChart
        }
    }
    
    private var trendChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let masturbationData = masturbationTrendData, let sexData = sexTrendData,
               !masturbationData.isEmpty || !sexData.isEmpty {
                Chart {
                    ForEach(masturbationData, id: \.startDate) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.startDate),
                            y: .value("Count", dataPoint.average)
                        )
                        .foregroundStyle(by: .value("Type", "Masturbation"))
                        .symbol(Circle())
                    }
                    
                    ForEach(sexData, id: \.startDate) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.startDate),
                            y: .value("Count", dataPoint.average)
                        )
                        .foregroundStyle(by: .value("Type", "Sex"))
                        .symbol(Circle())
                    }
                }
                .chartForegroundStyleScale([
                    "Masturbation": Color.blue,
                    "Sex": Color.pink
                ])
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: chartDateFormat, centered: true)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartLegend(position: .bottom)
                .frame(height: 250)
            } else {
                ContentUnavailableView {
                    Label("Not enough data", systemImage: "chart.line.uptrend.xyaxis")
                } description: {
                    Text("Add more events to see trends over time.")
                }
                .frame(height: 250)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    private var chartDateFormat: Date.FormatStyle {
        switch selectedPeriod {
        case .week:
            return .dateTime.month(.abbreviated).day()
        case .month:
            return .dateTime.month(.abbreviated).year(.twoDigits)
        case .year:
            return .dateTime.year()
        }
    }
    
    // MARK: - Helper Functions
    private func initializeDates() {
        guard !hasInitialized else { return }
        
        if let oldestEvent = events.first {
            startDate = oldestEvent.date
        }
        endDate = Date()
        hasInitialized = true
    }
    
    // MARK: - Calendar Section
    private var calendarSection: some View {
        VStack(spacing: 16) {
            Text("Calendar")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            // Legend
            HStack(spacing: 20) {
                legendItem(color: .blue, label: "Masturbation")
                legendItem(color: .red, label: "Sex")
                legendItem(color: .purple, label: "Both")
            }
            .font(.caption)
            .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(allMonthsInRange, id: \.self) { month in
                        monthView(for: month)
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 400)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
    
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
