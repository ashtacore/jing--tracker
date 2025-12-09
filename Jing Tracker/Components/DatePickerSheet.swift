//
//  DatePickerSheet.swift
//  Jing Tracker
//
//  Created by user287035 on 12/9/25.
//


struct DatePickerSheet: View {    @State private var selectedDate = Date()    let eventType: EventType?    let onConfirm: (Date) -> Void    let onCancel: () -> Void        var eventTitle: String {        switch eventType {        case .masturbation:            return "Log Masturbation"        case .sex:            return "Log Sex"        case .none:            return "Log Event"        }    }        var body: some View {        NavigationStack {            VStack(spacing: 20) {                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)                    .datePickerStyle(.graphical)                    .padding()            }            .navigationTitle(eventTitle)            .navigationBarTitleDisplayMode(.inline)            .toolbar {                ToolbarItem(placement: .cancellationAction) {                    Button("Cancel") {                        onCancel()                    }                }                ToolbarItem(placement: .confirmationAction) {                    Button("Confirm") {                        onConfirm(selectedDate)                    }                }            }        }        .presentationDetents([.medium, .large])    }}