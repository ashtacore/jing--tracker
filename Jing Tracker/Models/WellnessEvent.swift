//
//  Item.swift
//  Jing Tracker
//
//  Created by user287035 on 12/8/25.
//

import Foundation
import SwiftData

enum EventType: String, Codable {
    case masturbation, sex
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
