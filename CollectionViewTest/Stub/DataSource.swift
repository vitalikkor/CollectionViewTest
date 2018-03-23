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
    var hiddenEvents: [Date:[CalendarEvents]]
    
    init(dateInteval: DateInterval){
        visibleEvents = []
        hiddenEvents = [:]
        self.dateInteval = dateInteval
    }
}

struct MonthSectionEvent {
    let event: CalendarEvents
    let sectionLayout: MonthSectionEventLayout
}

struct MonthSectionEventLayout {
    let row: Int
    //possible indexes -1...n
    let column: Int//if column equal -1 it means that event have been started on previous week(section)
    let duration: Int
}

class DataSource {

    lazy var monthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    lazy var weekDayNamesDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    lazy var calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = .current
        cal.firstWeekday = 2
        return cal
    }()
    
    lazy var timeZone: TimeZone = {
        return calendar.timeZone
    }()

    lazy var currentDate: Date = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return Date().getStartOfDay(timeZone: self.timeZone)//dateFormatter.date(from: "2018-02-13T22:00:00.000+0000")!//
    }()
    
    private lazy var events: [CalendarEvents] = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let date1 = dateFormatter.date(from: "2018-02-13T22:00:00.000+0000")!//.getStartOfDay()

        let callEvent11 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call11", dateInterval: DateInterval(start: date1, duration: TimeInterval(3600*5)), channel: CallChannel.email, accountName: "Who", accountId: "Account1", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))

        let callEvent12 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call12", dateInterval: DateInterval(start: date1.addingTimeInterval(TimeInterval(3600*0)), duration: TimeInterval(3600*24*2)), channel: CallChannel.email, accountName: "Pony", accountId: "Account2", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))

//        let generalEvent11 = CalendarEvents.generalEvent(CalendarGeneralEvent(uid: "GE1", dateInterval: DateInterval(start: date1.addingTimeInterval(TimeInterval(3600*24*3)), duration: TimeInterval(3600*24*3)), isAllDay: false, name: "General Event1", description: "event description1"))
//
//        let generalEvent12 = CalendarEvents.generalEvent(CalendarGeneralEvent(uid: "GE2", dateInterval: DateInterval(start: date1.addingTimeInterval(TimeInterval(3600)), duration: TimeInterval(3600*24*4)), isAllDay: false, name: "General Event2", description: "event description2"))


        let date2 = dateFormatter.date(from: "2018-02-15T22:00:00.000+0000")!.getStartOfDay()

        let callEvent21 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call21", dateInterval: DateInterval(start: date2.addingTimeInterval(TimeInterval(3600*1)), duration: TimeInterval(3600*24*2)), channel: CallChannel.email, accountName: "Sort", accountId: "Account21", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))

        let callEvent22 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call22", dateInterval: DateInterval(start: date2.addingTimeInterval(TimeInterval(3600*2)), duration: TimeInterval(3600*24*1)), channel: CallChannel.email, accountName: "Typo", accountId: "Account22", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))
        
        let callEvent23 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call22", dateInterval: DateInterval(start: date2.addingTimeInterval(TimeInterval(3600*2)), duration: TimeInterval(3600*24*1)), channel: CallChannel.email, accountName: "Hidden", accountId: "Account22", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))
//
//        let date3 = date2.appendDays(days: 1)!
//
//        let totEvent31 = CalendarEvents.totEvent(CalendarTOTEvent(uid: "TOT31", dateInterval: DateInterval(start: date3.addingTimeInterval(TimeInterval(3600*2)), duration: TimeInterval(3600)), name: "tot-t", spanType: SnapType.hours, timeOff: "String", type: "String"))
        
        return [callEvent11,callEvent12,/* generalEvent11, generalEvent12,*/ callEvent21, callEvent22, callEvent23/*, totEvent31*/]
    }()
    
    let maxEventsPerDay = 3
    let weeksCountPerPage = 5
    let totalPagesCount = 3
    let daysCountPerWeek = 7

    private lazy var symmetricWeeksRange: [DateInterval] = {
        let middlePageNumber = (totalPagesCount+1)/2
        let firstWeekNumberOfMiddlePage = (middlePageNumber - 1)*weeksCountPerPage + 1
        let totalWeeksCount = weeksCountPerPage*totalPagesCount
        
        guard let firstDayOfSelectedMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)),
            let firstWeekOfSelectedMonth = calendar.dateInterval(of: .weekOfYear, for: firstDayOfSelectedMonth) else { return [] }
        var weeksArray: [DateInterval] = [firstWeekOfSelectedMonth]
        for i in 1..<firstWeekNumberOfMiddlePage {
            if let previouseWeekBeginning = calendar.date(byAdding: .weekOfYear, value: -i, to: firstWeekOfSelectedMonth.start),
                let previouseWeekEnd = calendar.date(byAdding: .weekOfYear, value: -i, to: firstWeekOfSelectedMonth.end) {
                let previouseWeekInterval = DateInterval(start: previouseWeekBeginning, end: previouseWeekEnd)
                weeksArray.insert(previouseWeekInterval, at: 0)
            } else {
                fatalError()
            }
        }
        for i in firstWeekNumberOfMiddlePage+1..<totalWeeksCount {
            let shiftedIndex = i - firstWeekNumberOfMiddlePage
            if let nextWeekBeginning = calendar.date(byAdding: .weekOfYear, value: shiftedIndex, to: firstWeekOfSelectedMonth.start),
                let nextWeekEnd = calendar.date(byAdding: .weekOfYear, value: shiftedIndex, to: firstWeekOfSelectedMonth.end){
                let nextWeekInterval = DateInterval(start: nextWeekBeginning, end: nextWeekEnd)
                weeksArray.insert(nextWeekInterval, at: weeksArray.count)
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
    
    func headerViewModel() -> CalendarMonthHeaderViewModel {
        let dateInterval = monthSections.first?.dateInteval ?? DateInterval()
        return CalendarMonthHeaderViewModel(dateFormatter: weekDayNamesDateFormatter, dateInterval: dateInterval, colorBackground: UIColor.lightGray)
    }
    
    func supplementaryViewModel(for indexPath: IndexPath) -> CalendarMonthSectionViewModel {
        let dateInterval = monthSections[indexPath.section].dateInteval
        let hidenItems = monthSections[indexPath.section].hiddenEvents.mapValues{$0.count}
        return CalendarMonthSectionViewModel(dateInterval: dateInterval, selectedMonthInterval: selectedMonth, dateFormatter: monthDateFormatter, numberOfHidenItemsPerDay: hidenItems)
    }
    
    func monthEventViewModel(for indexPath: IndexPath) -> CalendarMonthEventViewModel {
        let event = monthSections[indexPath.section].visibleEvents[indexPath.row].event
        let viewModel = CalendarMonthEventViewModel()
        viewModel.setupData(eventModel: event)
        return viewModel
    }
    
    var selectedMonth: DateInterval {
        guard let startMonth = self.currentDate.startOfMonth(timeZone: calendar.timeZone), let endMonth = self.currentDate.endOfMonth(timeZone: calendar.timeZone)?.addingTimeInterval(-1) else {
            return DateInterval()
        }
        return DateInterval(start: startMonth, end: endMonth)
    }
    
    private func composeMonthSections(with calendarEvents: [CalendarEvents]) {
        for weekInterval in self.symmetricWeeksRange {
            var rowIndexInsideWeek: Int?
            var alreadyPlacedIntervales: [[DateInterval]] = [[DateInterval]](repeating: [], count: maxEventsPerDay)
            var monthSection = MonthSection(dateInteval: weekInterval)
            let weekEvents = calendarEvents.filter{ event in
                if let intersection = event.dateInterval.intersection(with: weekInterval) {
                    return intersection.duration > 0
                }
                return false
            }
            var sortedWeekEvents = sortEvents(events: weekEvents, inside: weekInterval)
            while sortedWeekEvents.count > 0 {
                let event = sortedWeekEvents.removeFirst()
                guard let endDayOfEventEnd = event.dateInterval.end.getEndOfDay(timeZone: timeZone) else { fatalError()}
                let fullEventDayInterval = DateInterval(start: event.dateInterval.start.getStartOfDay(timeZone: timeZone), end: endDayOfEventEnd)
                rowIndexInsideWeek = self.findeIndexRowToPlace(dateInterval: fullEventDayInterval, placedIntervales: &alreadyPlacedIntervales, maxRowIndex: maxEventsPerDay)
                if let rowIndex = rowIndexInsideWeek {
                    var daysInsideWeekInterval = [Date]()
                    IteratableDateInterval(weekInterval).forEach{daysInsideWeekInterval.append($0)}
                    var columnNumber: Int
                    let daysDurationInWeek = daysDuration(of: event, in: weekInterval)
                    if let column = daysInsideWeekInterval.index(of: event.dateInterval.start.getStartOfDay(timeZone: timeZone)) {
                        columnNumber = column
                    } else {
                        columnNumber = -1
                    }
                    let monthEventLayout = MonthSectionEventLayout(row: rowIndex, column: columnNumber, duration: daysDurationInWeek)
                    let monthSectionEvent = MonthSectionEvent(event: event, sectionLayout: monthEventLayout)
                    monthSection.visibleEvents.append(monthSectionEvent)
                } else {
                    //fill hidden events array with appropriate date
                    if let intersectionInterval = weekInterval.intersection(with: event.dateInterval), intersectionInterval.duration > 0,
                        let ending = intersectionInterval.end.getEndOfDay(timeZone: timeZone)?.addingTimeInterval(1) {
                        let beginning = intersectionInterval.start.getStartOfDay(timeZone: timeZone)
                        IteratableDateInterval(DateInterval(start: beginning, end: ending)).forEach{ date in
                            let beginnigDate = date.getStartOfDay(timeZone: timeZone)
                            if monthSection.hiddenEvents[beginnigDate] != nil {
                                monthSection.hiddenEvents[beginnigDate]?.append(event)
                            } else {
                                monthSection.hiddenEvents[beginnigDate] = [event]
                            }
                        }
                    }
                    
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
        let beginingOfEndEventDate = event.dateInterval.end.getStartOfDay(timeZone: timeZone)
        guard let endEventDate = calendar.date(byAdding: .day, value: 1, to: beginingOfEndEventDate) else { return 0 }
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
