import SwiftUI

struct DayInfoPopup: View {
    @Binding private var selectedDate: Date
    @Binding private var events: [Date]

    var masturbationCount: Int {
        return events.filter { $0 == selectedDate && $0.type = .masturbation }.count
    }

    var sexCount: Int {
        return events.filter { $0 == selectedDate && $0.type == .sex }.count
    }
    
    var body: some View {
        VStack {
            Text("Date: \(selectedDate.formatted())")
            Text("Masturbation: \(masturbationCount)")
            Text("Sex: \(sexCount)")
        }
        .padding()
    }
}