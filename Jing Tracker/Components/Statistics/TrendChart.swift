import SwiftUI
import Charts

enum TimePeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

struct TrendChart: View {
    var masturbationDates: [Date]
    var sexDates: [Date]
    var endDate: Date
    @State private var selectedPeriod: TimePeriod = .week

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

    var body: some View {
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
                    "Masturbation": EventConstants.EventColor(for: .masturbation),
                    "Sex": EventConstants.EventColor(for: .sex)
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
    }
}
