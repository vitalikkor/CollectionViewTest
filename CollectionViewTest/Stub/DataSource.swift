//
//  DataSource.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/14/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import Foundation

class DataSource {
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
    
    lazy var monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter
    }()
    
    lazy var calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = self.timeZone
        return cal
    }()
    
    let timeZone = TimeZone.current
    
    lazy var currentDate: Date = {
        return Date().getStartOfDay(timeZone: self.timeZone)
    }()
    
    lazy var eventsDays: [CalendarEventDay] = {
        let date1 = dateFormatter.date(from: "2018-01-26T10:00:00.000+0000")!.getStartOfDay()
        let eventDay1 = CalendarEventDay(with: date1)
        
        let callEvent11 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call11", dateInterval: DateInterval.init(start: date1, duration: TimeInterval(3600)), channel: CallChannel.email, accountName: "Who", accountId: "Account1", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))
        
        let callEvent12 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call12", dateInterval: DateInterval(start: date1.addingTimeInterval(TimeInterval(3600*2)), duration: TimeInterval(3600)), channel: CallChannel.email, accountName: "Pony", accountId: "Account2", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))
        
        let generalEvent11 = CalendarEvents.generalEvent(CalendarGeneralEvent(uid: "GE1", dateInterval: DateInterval(start: date1.addingTimeInterval(TimeInterval(3600*5)), duration: TimeInterval(3600*24*3)), isAllDay: false, name: "General Event1", description: "event description1"))
        
        let generalEvent12 = CalendarEvents.generalEvent(CalendarGeneralEvent(uid: "GE2", dateInterval: DateInterval(start: date1.addingTimeInterval(TimeInterval(3600*5)), duration: TimeInterval(3600*24*3)), isAllDay: false, name: "General Event2", description: "event description2"))
        
        eventDay1.events.append(contentsOf: [generalEvent11, callEvent11, callEvent12, generalEvent12])
        
        let date2 = date1.appendDays(days: 1)!//dateFormatter.date(from: "2018-02-17T10:00:00.000+0000")!.getStartOfDay()
        let eventDay2 = CalendarEventDay(with: date2)
        
        let callEvent21 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call21", dateInterval: DateInterval(start: date2.addingTimeInterval(TimeInterval(3600*2)), duration: TimeInterval(3600)), channel: CallChannel.email, accountName: "Sort", accountId: "Account21", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))

        let callEvent22 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call22", dateInterval: DateInterval(start: date2.addingTimeInterval(TimeInterval(3600*2)), duration: TimeInterval(3600)), channel: CallChannel.email, accountName: "Typo", accountId: "Account22", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))
        
        eventDay2.events.append(contentsOf: [generalEvent12, callEvent21, callEvent22, generalEvent11])
        
        let date3 = date2.appendDays(days: 1)!
        let eventDay3 = CalendarEventDay(with: date3)
        let totEvent31 = CalendarEvents.totEvent(CalendarTOTEvent(uid: "TOT31", dateInterval: DateInterval(start: date3.addingTimeInterval(TimeInterval(3600*2)), duration: TimeInterval(3600)), name: "tot-t", spanType: SnapType.hours, timeOff: "String", type: "String"))
        eventDay3.events.append(contentsOf: [generalEvent12,totEvent31,generalEvent11])
        
        return [eventDay1, eventDay2, eventDay3]
        
        var eventDaysArray: [CalendarEventDay] = []
        for day in 1...105 {
            let newDay = date1.appendDays(days: day)!
            let eventDay = CalendarEventDay(with: newDay)
            for item in 1...5 {
                let dayShift = newDay//.appendHours(hours: 2)!
                let dateInterval = DateInterval(start: dayShift, duration: TimeInterval(3600))
                
                let randomCallEvent = CalendarEvents.callEvent(CalendarEventCall(uid: "Call\(day)\(item)", dateInterval: dateInterval, channel: CallChannel.email, accountName: "Who \(day)-\(item)", accountId: "Account\(day)\(item)", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))
                
                let totEvent = CalendarEvents.totEvent(CalendarTOTEvent(uid: "TOT\(day)\(item)", dateInterval: dateInterval, name: "tot-t", spanType: SnapType.hours, timeOff: "String", type: "String"))
                
                eventDay.events.append(randomCallEvent)
                eventDay.events.append(totEvent)
            }
            eventDaysArray.append(eventDay)
        }
        return eventDaysArray
    }()
    
    lazy var threeMonthsdateRange: [Date] = {
        var daysArray: [Date] = [currentDate]
        for i in 1...52 {
            if let next = calendar.date(byAdding: .day, value: i, to: currentDate) {
                daysArray.insert(next, at: daysArray.count)
            } else {
                fatalError()
            }
            if let previouse = calendar.date(byAdding: .day, value: -i, to: currentDate){
                daysArray.insert(previouse, at: 0)
            } else {
                fatalError()
            }
        }
        return daysArray
    }()
    
    func eventsInSection(_ section: Int) -> [CalendarEvents] {
        let dateBySection = threeMonthsdateRange[section]
        let events = eventsDays.first(where: {$0.date == dateBySection})?.events
        return events ?? []
    }
    
    func date(forSection: Int) -> String {
        return monthFormatter.string(from: threeMonthsdateRange[forSection])
    }
    
    
}
