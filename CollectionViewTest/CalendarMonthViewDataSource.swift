//
//  CalendarMonthViewDataSource.swift
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

class CalendarMonthViewDataSource {

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
        cal.firstWeekday = 1
        return cal
    }()
    
    lazy var timeZone: TimeZone = {
        return calendar.timeZone
    }()

    lazy var selectedDate: Date = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return Date().getStartOfDay(timeZone: self.timeZone)//dateFormatter.date(from: "2018-02-13T22:00:00.000+0000")!//
    }()
    
    private lazy var events: [CalendarEvents] = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let date1 = dateFormatter.date(from: "2018-02-13T22:00:00.000+0000")!//.getStartOfDay()

        let callEvent11 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call11", dateInterval: DateInterval(start: date1, duration: TimeInterval(3600*5)), channel: CallChannel.email, accountName: "callEvent11", accountId: "Account1", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))

        let callEvent12 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call12", dateInterval: DateInterval(start: date1.addingTimeInterval(TimeInterval(3600*0)), duration: TimeInterval(3600*24*2)), channel: CallChannel.email, accountName: "callEvent12", accountId: "accountId12", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))

        let generalEvent11 = CalendarEvents.generalEvent(CalendarGeneralEvent(uid: "GE1", dateInterval: DateInterval(start: date1.addingTimeInterval(TimeInterval(3600*24*3)), duration: TimeInterval(3600*24*2)), isAllDay: false, name: "generalEvent11", description: "event description1"))

        let generalEvent12 = CalendarEvents.generalEvent(CalendarGeneralEvent(uid: "GE2", dateInterval: DateInterval(start: date1.addingTimeInterval(TimeInterval(3600)), duration: TimeInterval(3600*24*4)), isAllDay: false, name: "generalEvent12", description: "event description2"))


        let date2 = dateFormatter.date(from: "2018-02-15T22:00:00.000+0000")!.getStartOfDay()

        let callEvent21 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call21", dateInterval: DateInterval(start: date2.addingTimeInterval(TimeInterval(3600*1)), duration: TimeInterval(3600*24*2)), channel: CallChannel.email, accountName: "callEvent21", accountId: "Account21", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))

        let callEvent22 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call22", dateInterval: DateInterval(start: date2.addingTimeInterval(TimeInterval(3600*2)), duration: TimeInterval(3600*24*1)), channel: CallChannel.email, accountName: "callEvent22", accountId: "Account22", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))
        
        let callEvent23 = CalendarEvents.callEvent(CalendarEventCall(uid: "Call22", dateInterval: DateInterval(start: date2.addingTimeInterval(TimeInterval(3600*2)), duration: TimeInterval(3600*24*1)), channel: CallChannel.email, accountName: "callEvent23", accountId: "Account22", status: OCEDBCallStatus.draft, signature: nil, submissionDate: nil))

        let date3 = date2.appendDays(days: 1)!

        let totEvent31 = CalendarEvents.totEvent(CalendarTOTEvent(uid: "TOT31", dateInterval: DateInterval(start: date3.addingTimeInterval(TimeInterval(3600*2)), duration: TimeInterval(3600)), name: "totEvent31", spanType: SnapType.hours, timeOff: "totEvent31", type: "totEvent31"))
        
        return [callEvent11,callEvent12, generalEvent11, generalEvent12, callEvent21, callEvent22, callEvent23, totEvent31]
    }()
    
    let maxEventsPerDay = 3
    let weeksCountPerPage = 5
    let totalPagesCount = 3
    let daysCountPerWeek = 7

    //builds range of weeks with selected month at the center
    private lazy var symmetricWeeksRange: [DateInterval] = {
        let middlePageNumber = (totalPagesCount+1)/2
        let firstWeekNumberOfMiddlePage = (middlePageNumber - 1)*weeksCountPerPage + 1
        let totalWeeksCount = weeksCountPerPage*totalPagesCount
        
        guard let firstDayOfSelectedMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)),
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
        for i in firstWeekNumberOfMiddlePage+1...totalWeeksCount {
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
    
    //returns the whole month which contains selected date
    private var selectedMonth: DateInterval {
        guard let startMonth = self.selectedDate.startOfMonth(timeZone: calendar.timeZone), let endMonth = self.selectedDate.endOfMonth(timeZone: calendar.timeZone)?.addingTimeInterval(-1) else {
            return DateInterval()
        }
        return DateInterval(start: startMonth, end: endMonth)
    }
    
    //composes the convenient data structure for each section(week) of the collectionView MonthSection
    private func composeMonthSections(with calendarEvents: [CalendarEvents]) {
        for weekInterval in self.symmetricWeeksRange {
            var rowIndexInsideWeek: Int?
            //this array contains date intervals from event interval and is used to check intersections between events
            var alreadyPlacedIntervales: [[DateInterval]] = [[DateInterval]](repeating: [], count: maxEventsPerDay)
            var monthSection = MonthSection(dateInteval: weekInterval)
            let weekEvents = calendarEvents.filter{ event in
                if let intersection = event.dateInterval.intersection(with: weekInterval) {
                    if intersection.duration > 0 {
                        return true
                    } else if intersection.duration == 0 {
                        return intersection.end != weekInterval.end
                    }
                }
                return false
            }
            var sortedWeekEvents = sortEvents(events: weekEvents, inside: weekInterval)
            while sortedWeekEvents.count > 0 {
                let event = sortedWeekEvents.removeFirst()
                guard let endDayOfEventEnd = event.dateInterval.end.getEndOfDay(timeZone: timeZone) else { fatalError()}
                //this dateInterval is event interval which is extended from left to the start of the day and from right to the end of the day
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
    //sorts events by the next rules: first of all by biggest event duration in current week and the second is by start date
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
    
    //eturns event duration, it is considered that if event continues at least one second of a day then on this day event has full one day duration
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
    
    //filled the 2 dimensional matrix of events duration for certain week.
    private func findeIndexRowToPlace(dateInterval: DateInterval, placedIntervales: inout [[DateInterval]], maxRowIndex: Int) -> Int? {
        var rowIndex = 0
        repeat  {
            //for first iteration no needs to check through all available rows for insertion
            if placedIntervales[rowIndex].count == 0 {
                placedIntervales[rowIndex].append(dateInterval)
                return rowIndex
            }
            var doesIntrevalIntersectAnyIntervals = true
            //iterate by all placed intervales to check if new one do not intersect them
            innerLoop: for placedIntervalesInRow in placedIntervales[rowIndex] {
                if placedIntervalesInRow.intersects(dateInterval) {
                    doesIntrevalIntersectAnyIntervals = true
                    break innerLoop
                } else {
                    doesIntrevalIntersectAnyIntervals = false
                }
            }
            if doesIntrevalIntersectAnyIntervals == false {
                placedIntervales[rowIndex].append(dateInterval)
                return rowIndex
            }
            rowIndex += 1
        } while rowIndex < maxRowIndex
        return nil
    }

}
