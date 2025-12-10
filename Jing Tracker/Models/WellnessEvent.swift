import Foundation
import SwiftData

enum EventType: String, Codable {
    case masturbation, sex
}

@Model
final class WellnessEvent {
    private var typeRawValue: String
    var date: Date
    
    var type: EventType {
        get { EventType(rawValue: typeRawValue) ?? .masturbation }
        set { typeRawValue = newValue.rawValue }
    }
    
    init(type: EventType, date: Date = Date()) {
        self.typeRawValue = type.rawValue
        self.date = date
    }
}
