import SwiftUI

struct CalendarList: View {
    @Binding var masturbationDates: [Date]
    @Binding var sexDates: [Date]
    @Binding var startDate: Date
    @Binding var endDate: Date

    @State private var selectedCalendarDate: Date? = nil
    @State private var showingDayDetail: Bool = false

    let calendarView = UICalendarView()
    calendarView.availableDateRange = DateInterval(start: startDate, end: endDate)

    // Calendar decorations
    let masturbationDecorator = UICalendarView.Decoration.default(
        color: EventConstants.EventUIColor(for: .masturbation),
        size: .small,
        shape: .circle
    )
    
    let sexDecorator = UICalendarView.Decoration.default(
        color: EventConstants.EventUIColor(for: .sex),
        size: .small,
        shape: .circle
    )

    let combinedDecorator = UICalendarView.Decoration.default(
        color: masturbationDecorator.color.blended(withFraction: 0.5, of: sexDecorator.color),
        size: .small,
        shape: .circle
    )

    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        return .customView {
            let emoji = UILabel()
            emoji.text = "🚀"
            return emoji
        }
    }

    func loadDecorations() {
        calendarView.reloadDecorations(
            forDateComponents: [dateComponents],
            animated: true
        )
    }


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

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }

    var body: some View {
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
}