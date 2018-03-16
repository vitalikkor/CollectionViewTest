//
//  CalendarEventDay.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/14/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import Foundation

class CalendarEventDay {
    var date: Date
    var events: [CalendarEvents] = []
    
    init (with date: Date) {
        self.date = date
    }
}

enum CalendarEvents: Equatable {
    case callEvent(CalendarEventCall)
    case generalEvent(CalendarGeneralEvent)
    case totEvent(CalendarTOTEvent)
    
    static func ==(lhs: CalendarEvents, rhs: CalendarEvents) -> Bool {
        switch (lhs, rhs) {
            case let (.callEvent(lEvent), .callEvent(rEvent)):
                return lEvent == rEvent
            case let (.generalEvent(lEvent), .generalEvent(rEvent)):
                return lEvent == rEvent
            case let (.totEvent(lEvent), .totEvent(rEvent)):
                return lEvent == rEvent
        default: return false
        }
    }
}


