import SwiftUI
import UIKit

private class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    var masturbationDates: [Date]
    var sexDates: [Date]
    var onDateSelected: (Date) -> Void
    
    private lazy var calendar = Calendar.current
    
    init(masturbationDates: [Date], sexDates: [Date], onDateSelected: @escaping (Date) -> Void) {
        self.blueDates = blueDates
        self.redDates = redDates
        self.onDateSelected = onDateSelected
    }
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        guard let date = calendar.date(from: dateComponents) else { return nil }
        
        let masturbationCount = masturbationDates.filter { calendar.isDate($0, inSameDayAs: date) }.count
        let sexCount = sexDates.filter { calendar.isDate($0, inSameDayAs: date) }.count
        
        if masturbationCount > 0 && sexCount > 0 {
            return .default(color: EventConstants.masturbationColor.blended(withFraction: 0.5, of: EventConstants.sexColor), size: .large)
        } else if masturbationCount > 0 {
            return .default(color: EventConstants.masturbationColor, size: .large)
        } else if sexCount > 0 {
            return .default(color: EventConstants.sexColor, size: .large)
        }
        
        return nil
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents,
                let date = calendar.date(from: dateComponents) else { return }
        
        onDateSelected(date)
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
        return true
    }
}

struct CalendarView: View {
    @Binding var masturbationDates: [Date]
    @Binding var sexDates: [Date]
    @Binding var startDate: Date
    @Binding var endDate: Date

    let onDateSelected: (Date) -> Void
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = Calendar.current
        calendarView.locale = Locale.current
        calendarView.fontDesign = .default
        
        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        calendarView.selectionBehavior = dateSelection
        calendarView.delegate = context.coordinator
        
        return calendarView
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.masturbationDates = masturbationDates
        context.coordinator.sexDates = sexDates
        context.coordinator.onDateSelected = onDateSelected
        uiView.reloadDecorations(forDateComponents: [], animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(masturbationDates: masturbationDates, sexDates: sexDates, onDateSelected: onDateSelected)
    }
}