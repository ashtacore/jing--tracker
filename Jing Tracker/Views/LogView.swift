import SwiftUI

struct LogView: View {
    var masturbationDates: [Date]
    var sexDates: [Date]
    let onLogEvent: (EventType, Date) -> Void
    
    @State private var showingDatePicker = false
    @State private var selectedEventType: EventType?
    @State private var loggedMasturbation = false
    @State private var loggedSex = false
    
    var hasMasturbatedToday: Bool {
        masturbationDates.contains(where: { Calendar.current.isDateInToday($0) })
    }
    
    var hadSexToday: Bool {
        sexDates.contains(where: { Calendar.current.isDateInToday($0) })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 20) {
                        EventButton(
                            title: "Masturbated Today",
                            icon: "hand.raised.fill",
                            isLogged: hasMasturbatedToday,
                            action: {
                                onLogEvent(.masturbation, Date())
                                loggedMasturbation.toggle()
                            }
                        )
                        .sensoryFeedback(.success, trigger: loggedMasturbation)
                        
                        Button {
                            selectedEventType = .masturbation
                            showingDatePicker = true
                        } label: {
                            Label("Log for Different Day", systemImage: "calendar")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    VStack(spacing: 20) {
                        EventButton(
                            title: "Had Sex Today",
                            icon: "heart.fill",
                            isLogged: hadSexToday,
                            action: {
                                onLogEvent(.sex, Date())
                                loggedSex.toggle()
                            }
                        )
                        .sensoryFeedback(.success, trigger: loggedSex)
                        
                        Button {
                            selectedEventType = .sex
                            showingDatePicker = true
                        } label: {
                            Label("Log for Different Day", systemImage: "calendar")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Activity")
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
                    .padding(.top, 30)
                }
                .padding(.vertical, 30)
            }
            .navigationTitle("Log Event")
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheet(
                    eventType: selectedEventType,
                    onConfirm: { date in
                        if let eventType = selectedEventType {
                            onLogEvent(eventType, date)
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
