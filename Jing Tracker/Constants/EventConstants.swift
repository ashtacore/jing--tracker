import SwiftUI

struct EventConstants {
    static let appName = "Jing Tracker"
    static let eventCooldown = TimeInterval(1 * 60) // 5 minutes in seconds

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
