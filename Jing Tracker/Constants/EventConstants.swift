import Foundation // or UIKit, SwiftUI, etc., depending on your needs

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
        case .Masturbation:
            return "hand.raised.fill"
        case .Sex:
            return "heart.fill"
        default:
            return "questionmark.circle"
        }
    }

    static func EventColor(for eventType: EventType) -> Color {
        switch eventType {
        case .Masturbation:
            return .blue
        case .Sex:
            return .pink
        default:
            return .gray
        }
    }
}