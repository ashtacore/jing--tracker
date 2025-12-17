import SwiftUI

struct EventConstants {
    // API related constants
    struct API {
        static let baseURL = "https://api.example.com"
        static let timeoutInterval: Double = 30.0
    }
    
    // General app settings
    static let appName = "MyApp"

    static func EventIcon(for eventType: EventType) -> String {
        switch eventType {
        case .masturbation:
            return "hand.raised.fill"
        case .sex:
            return "heart.fill"
        }
    }

    static func EventColor(for eventType: EventType) -> Color {
        switch eventType {
        case .masturbation:
            return .blue
        case .sex:
            return .pink
        }
    }
}
