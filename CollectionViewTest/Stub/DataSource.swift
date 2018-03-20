//
//  DataSource.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/14/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import Foundation
import UIKit

struct MonthSection {
    let dateInteval: DateInterval
    var visibleEvents: [MonthSectionEvent]
    var hidenEvents: [CalendarEvents]
    
    init(dateInteval: DateInterval){
        visibleEvents = []
        hidenEvents = []
        self.dateInteval = dateInteval
    }
}

struct MonthSectionEvent {
    let event: CalendarEvents
    let sectionLayout: MonthSectionEventLayout
}

struct MonthSectionEventLayout {
    let row: Int
    let column: Int
    let duration: Int
}

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
    
    let daysCountInWeek = 7
    let maxEventsPerDay = 3
    
    lazy var currentDate: Date = {
        return Date().getStartOfDay(timeZone: self.timeZone)
    }()
    
    private lazy var events: [CalendarEvents] = {
        let date1 = dateFormatter.date(from: "2018-02-01T22:00:00.000+0000")!.getStartOfDay()
        
        let callEvent11 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call11", dateInterval: DateInterval.init(start: date1, duration: TimeInterval(3600)), channel: CallChannel.email, accountName: "Who", accountId: "Account1", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))

        let callEvent12 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call12", dateInterval: DateInterval(start: date1.addingTimeInterval(TimeInterval(3600*2)), duration: TimeInterval(3600)), channel: CallChannel.email, accountName: "Pony", accountId: "Account2", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))

        let generalEvent11 = CalendarEvents.generalEvent(CalendarGeneralEvent(uid: "GE1", dateInterval: DateInterval(start: date1.addingTimeInterval(TimeInterval(3600*24*3)), duration: TimeInterval(3600*24*3)), isAllDay: false, name: "General Event1", description: "event description1"))

        let generalEvent12 = CalendarEvents.generalEvent(CalendarGeneralEvent(uid: "GE2", dateInterval: DateInterval(start: date1.addingTimeInterval(TimeInterval(3600)), duration: TimeInterval(3600*24*4)), isAllDay: false, name: "General Event2", description: "event description2"))

//
//        let date2 = date1.appendDays(days: 1)!//dateFormatter.date(from: "2018-02-17T10:00:00.000+0000")!.getStartOfDay()
//
//        let callEvent21 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call21", dateInterval: DateInterval(start: date2.addingTimeInterval(TimeInterval(3600*2)), duration: TimeInterval(3600)), channel: CallChannel.email, accountName: "Sort", accountId: "Account21", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))
//
//        let callEvent22 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call22", dateInterval: DateInterval(start: date2.addingTimeInterval(TimeInterval(3600*2)), duration: TimeInterval(3600)), channel: CallChannel.email, accountName: "Typo", accountId: "Account22", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))
//
//        let date3 = date2.appendDays(days: 1)!
//
//        let totEvent31 = CalendarEvents.totEvent(CalendarTOTEvent(uid: "TOT31", dateInterval: DateInterval(start: date3.addingTimeInterval(TimeInterval(3600*2)), duration: TimeInterval(3600)), name: "tot-t", spanType: SnapType.hours, timeOff: "String", type: "String"))
        
        return [callEvent11,callEvent12, generalEvent11, generalEvent12/*, callEvent21, callEvent22, totEvent31*/]
    }()
    
    private lazy var symmetricWeeksRange: [DateInterval] = {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        guard let currentWeek = calendar.dateInterval(of: Calendar.Component.weekOfYear, for: currentDate) else { return [] }
        var weeksArray: [DateInterval] = [currentWeek]
        for i in 1...7 {
            if let nextWeekBeginning = calendar.date(byAdding: .weekOfYear, value: i, to: currentWeek.start),
                 let nextWeekEnd = calendar.date(byAdding: .weekOfYear, value: i, to: currentWeek.end){
                let nextWeekInterval = DateInterval(start: nextWeekBeginning, end: nextWeekEnd)
                weeksArray.insert(nextWeekInterval, at: weeksArray.count)
            } else {
                fatalError()
            }
            if let previouseWeekBeginning = calendar.date(byAdding: .weekOfYear, value: -i, to: currentWeek.start),
                let previouseWeekEnd = calendar.date(byAdding: .weekOfYear, value: -i, to: currentWeek.end) {
                let previouseWeekInterval = DateInterval(start: previouseWeekBeginning, end: previouseWeekEnd)
                weeksArray.insert(previouseWeekInterval, at: 0)
            } else {
                fatalError()
            }
        }
        return weeksArray
    }()
    
    init() {
        fetchEvents { (calendarEvents) in
            composeMonthSections(with: calendarEvents)
        }
    }
    
    var monthSections: [MonthSection] = []
    
    private func fetchEvents(calback: ([CalendarEvents])->Void){
        calback(events)
    }
    
    func events(in section: Int) -> [CalendarEvents]{
        return monthSections[section].visibleEvents.map{$0.event}
    }
    
    private func composeMonthSections(with calendarEvents: [CalendarEvents]) {
        for weekInterval in self.symmetricWeeksRange {
            var rowIndexInsideWeek: Int?
            var alreadyPlacedIntervales: [[DateInterval]] = [[DateInterval]](repeating: [], count: maxEventsPerDay)
            var monthSection = MonthSection(dateInteval: weekInterval)
            let weekEvents = calendarEvents.filter{ $0.dateInterval.intersects(weekInterval)}
            var sortedWeekEvents = sortEvents(events: weekEvents, inside: weekInterval)
            while sortedWeekEvents.count > 0 {
                let event = sortedWeekEvents.removeFirst()
                let allDayInterval = DateInterval(start: event.dateInterval.start.getStartOfDay(timeZone: timeZone), end: event.dateInterval.end.getEndOfDay(timeZone: timeZone)!)
                rowIndexInsideWeek = self.findeIndexRowToPlace(dateInterval: allDayInterval, placedIntervales: &alreadyPlacedIntervales, maxRowIndex: maxEventsPerDay)
                if let rowIndex = rowIndexInsideWeek {
                    var daysInsideWeekInterval = [Date]()
                    IteratableDateInterval(weekInterval).forEach{daysInsideWeekInterval.append($0)}
                    let columnNumber: Int
                    let daysDurationInWeek = daysDuration(of: event, in: weekInterval)
                    if let column = daysInsideWeekInterval.index(of: event.dateInterval.start.getStartOfDay(timeZone: timeZone)) {
                        columnNumber = column
                    } else {
                        columnNumber = 0
                    }
                    let monthEventLayout = MonthSectionEventLayout(row: rowIndex, column: columnNumber, duration: daysDurationInWeek)
                    let monthSectionEvent = MonthSectionEvent(event: event, sectionLayout: monthEventLayout)
                    monthSection.visibleEvents.append(monthSectionEvent)
                } else {
                    monthSection.hidenEvents.append(event)
                }
            }
            monthSections.append(monthSection)
        }
    }
    
    private func sortEvents(events: [CalendarEvents], inside weekInterval: DateInterval) -> [CalendarEvents] {
        return events.sorted {
            let beginningOfIntervalLeftItem = max($0.dateInterval.start, weekInterval.start).getStartOfDay(timeZone: timeZone)
            let beginningOfIntervalRightItem = max($1.dateInterval.start, weekInterval.start).getStartOfDay(timeZone: timeZone)
            guard let endingOfIntervalLeftItem = $0.dateInterval.end.getEndOfDay(timeZone: timeZone),
                let endingOfIntervalRightItem = $1.dateInterval.end.getEndOfDay(timeZone: timeZone) else { fatalError() }
            let leftDaysDuration = DateInterval(start: beginningOfIntervalLeftItem, end: endingOfIntervalLeftItem).duration
            let rightDaysDuration = DateInterval(start: beginningOfIntervalRightItem, end: endingOfIntervalRightItem).duration
            return (leftDaysDuration, $1.dateInterval.start) > (rightDaysDuration, $0.dateInterval.start)
        }
    }
    
    private func daysDuration(of event: CalendarEvents, in weekInterval: DateInterval) -> Int {
        guard let endEventDate = event.dateInterval.end.getEndOfDay(timeZone: timeZone) else { return 0 }
        var count = 0
        let minimalDaysDuration = 1
        let eventBeginning = max(event.dateInterval.start.getStartOfDay(timeZone: timeZone), weekInterval.start)
        IteratableDateInterval(DateInterval(start: eventBeginning, end: endEventDate), .day, calendar).forEach {_ in
            count += 1
        }
        return max(count,minimalDaysDuration)
    }
    
    private func findeIndexRowToPlace(dateInterval: DateInterval, placedIntervales: inout [[DateInterval]], maxRowIndex: Int) -> Int? {
        var rowIndex = 0
        repeat  {
            if placedIntervales[rowIndex].count == 0 {
                placedIntervales[rowIndex].append(dateInterval)
                return rowIndex
            }
            innerLoop: for placedIntervalesInRow in placedIntervales[rowIndex] {
                if placedIntervalesInRow.intersects(dateInterval) {
                    rowIndex += 1
                    break innerLoop
                } else {
                    placedIntervales[rowIndex].append(dateInterval)
                    return rowIndex
                }
            }
        } while rowIndex < maxRowIndex
        return nil
    }

}
