//
//  CalendarEventDay.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/14/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import Foundation

enum CalendarEvents: Equatable, CalendarEvent {
    
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
    
    var uid: String {
        return uidString()
    }
    
    var dateInterval: DateInterval {
        return eventDateInterval()
    }
    
    var isAllDay: Bool {
        return isAllDayEvent()
    }
    
    private func uidString() -> String {
        switch self {
        case let .callEvent(callEvent):
            return callEvent.uid
        case let .generalEvent(generalEvent):
            return generalEvent.uid
        case let .totEvent(totEvent):
            return totEvent.uid
        }
    }
    
    private func eventDateInterval() -> DateInterval {
        switch self {
        case let .callEvent(callEvent):
            return callEvent.dateInterval
        case let .generalEvent(generalEvent):
            return generalEvent.dateInterval
        case let .totEvent(totEvent):
            return totEvent.dateInterval
        }
    }
    
    private func isAllDayEvent() -> Bool {
        switch self {
        case let .callEvent(callEvent):
            return callEvent.isAllDay
        case let .generalEvent(generalEvent):
            return generalEvent.isAllDay
        case let .totEvent(totEvent):
            return totEvent.isAllDay
        }
    }
    
}


