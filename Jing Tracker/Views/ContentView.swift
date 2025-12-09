//
//  ContentView.swift
//  Jing Tracker
//
//  Created by user287035 on 12/8/25.
//



import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WellnessEvent.date, order: .reverse) private var events: [WellnessEvent]
    
    var masturbationDates: [Date] {
        events.filter { $0.type == .masturbation }.map { $0.date }
    }
    
    var sexDates: [Date] {
        events.filter { $0.type == .sex }.map { $0.date }
    }
    
    var body: some View {
        TabView {
            LogView(
                masturbationDates: masturbationDates,
                sexDates: sexDates,
                onLogEvent: logEvent
            )
            .tabItem {
                Label("Log", systemImage: "plus.circle.fill")
            }
            
            StatisticsView(
                masturbationDates: masturbationDates,
                sexDates: sexDates
            )
            .tabItem {
                Label("Statistics", systemImage: "chart.bar.fill")
            }
        }
    }
    
    func logEvent(type: EventType, date: Date = Date()) {
        let calendar = Calendar.current
        
        // Check if event already exists for this day and type
        let existingEvents: [Date]
        switch type {
        case .masturbation:
            existingEvents = masturbationDates
        case .sex:
            existingEvents = sexDates
        }
        
        if !existingEvents.contains(where: { calendar.isDate($0, inSameDayAs: date) }) {
            let newEvent = WellnessEvent(type: type, date: date)
            modelContext.insert(newEvent)
        }
    }
}
#Preview {
    ContentView()
        .modelContainer(for: WellnessEvent.self, inMemory: true)
}
