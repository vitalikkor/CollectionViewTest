//
//  GeneralEventStaff.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/14/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import Foundation

struct CalendarGeneralEvent: CalendarEvent {
    // MARK: - CalendarEvent protocol properties
    let uid: String
    let dateInterval: DateInterval
    let isAllDay: Bool
    // other specific properties
    let name: String
    let description: String
}

extension CalendarGeneralEvent: Hashable, Equatable {
    var hashValue: Int {
        return uid.hashValue
    }
    
    static func ==(lhs: CalendarGeneralEvent, rhs: CalendarGeneralEvent) -> Bool {
        return lhs.uid == rhs.uid
    }
}
