import SwiftUI

struct StatisticsView: View {
    var masturbationDates: [Date]
    var sexDates: [Date]
    
    enum TimePeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    @State private var selectedPeriod: TimePeriod = .week
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    Picker("Time Period", selection: $selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    VStack(spacing: 20) {
                        StatCard(
                            title: "Masturbation",
                            icon: "hand.raised.fill",
                            color: .blue,
                            average: calculateAverage(for: masturbationDates, period: selectedPeriod),
                            total: countEvents(for: masturbationDates, period: selectedPeriod),
                            period: selectedPeriod
                        )
                        
                        StatCard(
                            title: "Sex",
                            icon: "heart.fill",
                            color: .pink,
                            average: calculateAverage(for: sexDates, period: selectedPeriod),
                            total: countEvents(for: sexDates, period: selectedPeriod),
                            period: selectedPeriod
                        )
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("All Time Stats")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Total Masturbation")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Text("\(masturbationDates.count)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                                Spacer()
                                Image(systemName: "hand.raised.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.blue)
                            }
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Total Sex")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Text("\(sexDates.count)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                                Spacer()
                                Image(systemName: "heart.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.pink)
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
        }
    }
    
    func calculateAverage(for dates: [Date], period: TimePeriod) -> Double {
        let count = countEvents(for: dates, period: period)
        let days = daysInPeriod(period)
        return Double(count) / Double(days)
    }
    
    func countEvents(for dates: [Date], period: TimePeriod) -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch period {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now)!
        }
        
        return dates.filter { $0 >= startDate }.count
    }
    
    func daysInPeriod(_ period: TimePeriod) -> Int {
        switch period {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }
}
