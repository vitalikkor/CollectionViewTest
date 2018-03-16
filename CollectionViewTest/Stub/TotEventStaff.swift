//
//  TotEventStaff.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/14/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import Foundation

struct CalendarTOTEvent: CalendarEvent {
    // MARK: - CalendarEvent protocol properties
    let uid: String
    let dateInterval: DateInterval
    var isAllDay: Bool {
        return spanType == SnapType.days
    }
    // other specific properties
    let name: String
    let spanType: SnapType
    let timeOff: String
    let type: String
}

enum SnapType: String, Codable {
    case days = "Days"
    case hours = "Hours"
}

extension CalendarTOTEvent: Hashable, Equatable {
    var hashValue: Int {
        return uid.hashValue
    }
    
    static func ==(lhs: CalendarTOTEvent, rhs: CalendarTOTEvent) -> Bool {
        return lhs.uid == rhs.uid
    }
}
