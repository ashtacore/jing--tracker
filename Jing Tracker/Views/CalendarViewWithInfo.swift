import SwiftUI
import SwiftUICalendar
import SwiftData

struct CalendarViewWithInfo: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WellnessEvent.date, order: .forward) private var events: [WellnessEvent]
    
    @ObservedObject var controller = CalendarController()
    @State var focusDate: YearMonthDay? = nil
    
    var focusEvents: [EventType] {
        guard let focusDate else { return [] }
        let calendar = Calendar.current
        
        return events.filter {
            let components = calendar.dateComponents([.year, .month, .day], from: $0.date)
            return YearMonthDay(year: components.year!, month: components.month!, day: components.day!) == focusDate
        }.map { $0.type }
    }
    
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
    
    func countFor(event: EventType) -> Int {
        focusEvents.filter { $0 == event }.count
    }
    
    func logEvent(type: EventType) {
        guard focusDate != nil else { return }
        let newEvent = WellnessEvent(type: type, date: focusDate!.date!)
        modelContext.insert(newEvent)
    }
    
    func removeEvent() {
        guard focusDate != nil else { return }
        let eventToRemove = events.first(where: { $0.date == focusDate!.date })
        guard eventToRemove != nil else { return }
        
        modelContext.delete(eventToRemove!)
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
                .foregroundStyle(Color.purpleAccent.opacity(0.95))
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
                                    .background(Color.purpleAccent.opacity(0.95))
                                    .cornerRadius(14)
                            } else {
                                Text("\(date.day)")
                                    .font(.system(size: 10, weight: .light, design: .default))
                                    .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                                    .foregroundColor(Color.primary)
                                    .padding(4)
                            }
                            if let daysEvents = informations[date] {
                                ForEach(EventType.allCases) { event in
                                    let eventCount = daysEvents.count { $0 == event }
                                    if eventCount > 0 {
                                        let color = event.color.opacity(0.75)
                                        if focusDate != nil {
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
                                } else {
                                    focusDate = date
                                }
                            }
                        }
                    }
                })
                if focusDate != nil {
                    List(EventType.allCases) { event in
                        let eventCount = countFor(event: event)
                        let color = event.color.opacity(0.75)
                        
                        HStack(alignment: .center, spacing: 0) {
                            Circle()
                                .fill(color)
                                .frame(width: 12, height: 12)
                            Text("\(event.title)")
                                .padding(.leading, 8)
                            
                            Spacer()
                            
                            Button(action: { logEvent(type: event) }) {
                                Label("", systemImage: "plus")
                                    .labelStyle(.iconOnly)
                                    .foregroundStyle(.green)
                            }
                            .buttonStyle(.borderless)
                            
                            Text("x\(eventCount)")
                                .padding(8)
                                .frame(minWidth: 40)
                            
                            Button(action: removeEvent) {
                                Label("", systemImage: "minus")
                                    .labelStyle(.iconOnly)
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .frame(width: reader.size.width, height: 160, alignment: .center)
                }
            }
        }
    }
}

#Preview {
    CalendarViewWithInfo()
        .modelContainer(MockDataGenerator.makeContainer())
}
