import SwiftUI
import SwiftUICalendar
import SwiftData

struct CalendarViewWithInfo: View {
    @Query(sort: \WellnessEvent.date, order: .forward) private var events: [WellnessEvent]
    
    @ObservedObject var controller = CalendarController()
    @State var focusDate: YearMonthDay? = nil
    @State var focusInfo: [EventType]? = nil
    
    private var informations: [YearMonthDay: [EventType]] {
        var result = [YearMonthDay: [EventType]]()
        let calendar = Calendar.current
        
        for event in events {
            let components = calendar.dateComponents([.year, .month, .day], from: event.date)
            guard let year = components.year,
                  let month = components.month,
                  let day = components.day else { continue }
            
            let ymd = YearMonthDay(year: year, month: month, day: day)
            if result[ymd] == nil {
                result[ymd] = []
            }
            result[ymd]?.append(event.type)
        }
        
        return result
    }

    var body: some View {
        GeometryReader { reader in
            VStack {
                Text("\(controller.yearMonth.monthShortString), \(String(controller.yearMonth.year))")
                    .font(.title)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                Button("Today") {
                    controller.scrollTo(YearMonth.current, isAnimate: true)
                }
                CalendarView(controller, header: { week in
                    GeometryReader { geometry in
                        Text(week.shortString)
                            .font(.subheadline)
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    }
                }, component: { date in
                    GeometryReader { geometry in
                        VStack(alignment: .leading, spacing: 2) {
                            if date.isToday {
                                Text("\(date.day)")
                                    .font(.system(size: 10, weight: .bold, design: .default))
                                    .padding(4)
                                    .foregroundColor(.white)
                                    .background(Color.purple.opacity(0.95))
                                    .cornerRadius(14)
                            } else {
                                Text("\(date.day)")
                                    .font(.system(size: 10, weight: .light, design: .default))
                                    .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                                    .foregroundColor(getColor(date))
                                    .padding(4)
                            }
                            if let daysEvents = informations[date] {
                                ForEach(EventType.allCases) { event in
                                    let eventCount = daysEvents.count { $0 == event }
                                    if eventCount > 0 {
                                        let color = event.color.opacity(0.75)
                                        if focusInfo != nil {
                                            Rectangle()
                                                .fill(color)
                                                .frame(width: geometry.size.width, height: 4, alignment: .center)
                                                .cornerRadius(2)
                                                .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                                        } else {
                                            Text(event.title)
                                                .lineLimit(1)
                                                .foregroundColor(.white)
                                                .font(.system(size: 8, weight: .bold, design: .default))
                                                .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
                                                .frame(width: geometry.size.width, alignment: .center)
                                                .background(color)
                                                .cornerRadius(4)
                                                .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                        .border(.green.opacity(0.8), width: (focusDate == date ? 1 : 0))
                        .cornerRadius(2)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                if focusDate == date {
                                    focusDate = nil
                                    focusInfo = nil
                                } else {
                                    focusDate = date
                                    focusInfo = informations[date]
                                }
                            }
                        }
                    }
                })
                if let daysEvents = focusInfo {
                    List(EventType.allCases) { event in
                        let eventCount = daysEvents.count { $0 == event }
                        let color = event.color.opacity(0.75)
                        HStack(alignment: .center, spacing: 0) {
                            Circle()
                                .fill(color)
                                .frame(width: 12, height: 12)
                            Text("\(event.title) x\(eventCount)")
                                .padding(.leading, 8)
                        }
                    }
                    .frame(width: reader.size.width, height: 160, alignment: .center)
                }
            }
        }
    }
    
    private func getColor(_ date: YearMonthDay) -> Color {
        if date.dayOfWeek == .sun {
            return Color.primary
        } else {
            return Color.black
        }
    }
}

struct CalendarViewWithInfo_Previews: PreviewProvider {
    static var previews: some View {
        CalendarViewWithInfo()
    }
}
