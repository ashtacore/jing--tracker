import SwiftUI
import SwiftData

enum EventType: String, Codable, CaseIterable, Identifiable {
    case masturbation, sex
    
    var id: String {
        self.rawValue
    }
    
    var title: String {
        self.rawValue.capitalized
    }
    
    var icon: String {
        switch self {
            case .masturbation:
                return "hand.raised.fill"
            case .sex:
                return "heart.fill"
            }
    }
    
    var color: Color {
        switch self {
            case .masturbation:
                return .blue
            case .sex:
                return .red
            }
    }
}

@Model
final class WellnessEvent {
    var type: EventType
    var date: Date
    
    init(type: EventType, date: Date = Date()) {
        self.type = type
        self.date = date
    }
}
