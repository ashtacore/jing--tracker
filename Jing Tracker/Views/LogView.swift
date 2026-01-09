import SwiftUI
import SwiftData

struct LogView: View {
    @State private var currentTime = Date()
    @Environment(\.modelContext) private var modelContext
    
    static var thirtyDaysAgo: Date {
            Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        }
    @Query(filter: #Predicate<WellnessEvent> { event in
        event.date >= thirtyDaysAgo
    }, sort: \WellnessEvent.date, order: .reverse) private var recentEvents: [WellnessEvent]
    
    // Date Picker control variables
    @State private var showingDatePicker = false
    @State private var selectedEventType: EventType?

    // Cache for last events to avoid unnecessary fetches
    @State private var cachedLastMasturbation: Date?
    @State private var cachedLastSex: Date?

    var masturbationDates: [Date] {
        recentEvents.filter { $0.type == .masturbation }.map { $0.date }
    }
    
    var todaysMasturbation: [Date] {
        let calendar = Calendar.current
        return masturbationDates.filter { calendar.isDate($0, inSameDayAs: Date()) }
    }
    
    var sexDates: [Date] {
        recentEvents.filter { $0.type == .sex }.map { $0.date }
    }
    
    var todaysSex: [Date] {
        let calendar = Calendar.current
        return sexDates.filter { calendar.isDate($0, inSameDayAs: Date()) }
    }

    func logEvent(type: EventType, date: Date = Date()) {
        let newEvent = WellnessEvent(type: type, date: date)
        modelContext.insert(newEvent)
        
        // Update last event cache
        switch type {
            case .masturbation: cachedLastMasturbation = date
            case .sex: cachedLastSex = date
        }
    }

    init() {
        cachedLastMasturbation = recentEvents.first(where: { $0.type == .masturbation })?.date
        
        // Only fetch if no recent masturbation
        if cachedLastMasturbation == nil {
            let typeRawValue = EventType.masturbation.rawValue
            let descriptor = FetchDescriptor<WellnessEvent>(
                predicate: #Predicate { $0.type.rawValue == typeRawValue },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            if let result = try? modelContext.fetch(descriptor).first {
                cachedLastMasturbation = result.date
            }
        }
        
        cachedLastSex = recentEvents.first(where: { $0.type == .sex})?.date
        
        // Only fetch if no recent sex
        if cachedLastSex == nil {
            let typeRawValue = EventType.sex.rawValue
            let descriptor = FetchDescriptor<WellnessEvent>(
                predicate: #Predicate { $0.type.rawValue == typeRawValue },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            if let result = try? modelContext.fetch(descriptor).first {
                cachedLastSex = result.date
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 20) {
                        EventButton(
                            title: "Masturbated Today",
                            icon: "hand.raised.fill",
                            todaysCount: todaysMasturbation.count,
                            action: {
                                logEvent(type: .masturbation)
                            }
                        )
                        .sensoryFeedback(.success, trigger: cachedLastMasturbation)
                        
                        Button {
                            selectedEventType = .masturbation
                            showingDatePicker = true
                        } label: {
                            Label("Log for Different Day", systemImage: "calendar")
                                .font(.subheadline)
                                .foregroundStyle(.purpleAccent)
                        }
                    }
                    
                    VStack(spacing: 20) {
                        EventButton(
                            title: "Had Sex Today",
                            icon: "heart.fill",
                            todaysCount: todaysSex.count,
                            action: {
                                logEvent(type: .sex)
                            }
                        )
                        .sensoryFeedback(.success, trigger: cachedLastSex)
                        
                        Button {
                            selectedEventType = .sex
                            showingDatePicker = true
                        } label: {
                            Label("Log for Different Day", systemImage: "calendar")
                                .font(.subheadline)
                                .foregroundStyle(.purpleAccent)
                        }
                    }
                    .padding(.top, 15)

                    Divider()
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last 30 Days")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "hand.raised.fill")
                                    .foregroundStyle(.blue)
                                    .frame(width: 30)
                                Text("Masturbation: \(masturbationDates.count) events")
                            }
                            
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.pink)
                                    .frame(width: 30)
                                Text("Sex: \(sexDates.count) events")
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last Event")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "hand.raised.fill")
                                    .foregroundStyle(.blue)
                                    .frame(width: 30)
                                Text(cachedLastMasturbation == nil ? "Masturbation: No data yet" : "Masturbation: \(Int(abs(cachedLastMasturbation!.timeIntervalSinceNow / 86400))) days ago")
                            }
                            
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.pink)
                                    .frame(width: 30)
                                Text(cachedLastSex == nil ? "Sex: No data yet" : "Sex: \(Int(abs(cachedLastSex!.timeIntervalSinceNow / 86400))) days ago")
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 15)
            }
            .navigationTitle("Log Event")
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheet(
                    eventType: selectedEventType,
                    onConfirm: { date in
                        if let eventType = selectedEventType {
                            logEvent(type: eventType, date: date)
                        }
                        showingDatePicker = false
                    },
                    onCancel: {
                        showingDatePicker = false
                    }
                )
            }
        }
    }
}

#Preview {
    LogView()
        .modelContainer(for: WellnessEvent.self, inMemory: true)
}
