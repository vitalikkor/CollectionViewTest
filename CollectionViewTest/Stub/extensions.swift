//
//  extensions.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/14/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import Foundation

enum DayOfWeek: Int {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    init(value: String?) {
        guard let valueString = value else {
            self = .monday
            return
        }
        switch valueString.lowercased() {
        case "monday":
            self = .monday
        case "sunday" :
            self = .sunday
        case "tuesday" :
            self = .tuesday
        case "wednesday":
            self = .wednesday
        case "thursday" :
            self = .thursday
        case "friday" :
            self = .friday
        case "saturday" :
            self = .saturday
        default:
            self = .monday
        }
    }
    
    func nameOfDay() -> String {
        switch self {
        case .monday:
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thursday"
        case .friday:
            return "Friday"
        case .saturday:
            return "Saturday"
        case .sunday:
            return "Sunday"
        }
    }
    
}

extension Date {
   
    
    func getFirstDateOfMonth(timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)
    }
    
    func getLastDateOfMonth(timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        guard let daysCountInMonth = calendar.range(of: .day, in: .month, for: self)?.count else { return nil }
        let dateComponent = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: dateComponent)?.addingTimeInterval(daysInterval(count: daysCountInMonth) - 1/*second*/)
    }
    
    func getNextYearDate(timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.date(byAdding: .year, value: 1, to: self)
    }
    
    func getPreviousYearDate(timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.date(byAdding: .year, value: -1, to: self)
    }
    
    func getNextMonthDate(timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.date(byAdding: .month, value: 1, to: self)
    }
    
    func getPreviousMonthDate(timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.date(byAdding: .month, value: -1, to: self)
    }
    
    func getNextDay(timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.date(byAdding: .day, value: 1, to: self)
    }
    
    func roundTime(to minutes: Double, timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        let currentMinute = Double(calendar.component(.minute, from: self))
        let roundedMinutes = (currentMinute / minutes).rounded(.up) * minutes
        let difference = Int(abs(roundedMinutes - currentMinute))
        return calendar.date(byAdding: .minute, value: difference, to: self)
    }
    
    func appendDays(days: Int, timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.date(byAdding: .day, value: days, to: self)
    }
    
    func append(component: Calendar.Component, value: Int, timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.date(byAdding: component, value: value, to: self)
    }
    
    func appendHours(hours: Int, timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.date(byAdding: .hour, value: hours, to: self)
    }
    
    func getPreviousDay(timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.date(byAdding: .day, value: -1, to: self)
    }
    
    func getNextWeekDay(timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.date(byAdding: .weekOfYear, value: 1, to: self)
    }
    
    func getPreviousWeekDay(timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.date(byAdding: .weekOfYear, value: -1, to: self)
    }
    
    func daysInterval(count: Int) -> TimeInterval {
        return TimeInterval(60*60*24*count)
    }
    
    func startOfMonth(timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: self)))
    }
    
    func endOfMonth(timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        guard   let startOfMonth = self.startOfMonth(timeZone: timeZone),
            let range = calendar.range(of: .day, in: .month, for: self)
            else { return nil }
        let numDays = range.count
        return startOfMonth.appendDays(days: numDays, timeZone: timeZone)
    }
    
    func getStartDateOfWeek(value: DayOfWeek = .monday, timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        guard let supposedStartDateOfWeek = calendar.date(bySetting: .weekday, value: value.rawValue, of: self) else { return nil}
        //Supposed Start Date Of Week is more by 7 days then expected value if input date(self) more then first date of week
        let startDay = calendar.startOfDay(for: supposedStartDateOfWeek)
        if self < startDay {
            return calendar.date(byAdding: .day, value: -7, to: startDay)
        } else {
            return startDay
        }
    }
    
    func getEndDateOfWeek(value: DayOfWeek = .monday, timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        let startOfWeekDate = getStartDateOfWeek(value: value, timeZone: timeZone)
        return startOfWeekDate?.addingTimeInterval(TimeInterval(daysInterval(count: 7) - 1/*second*/))
    }
    
    
    //return set of dates starts from self time to end time
    func datesArray(to endDate: Date, timeZone: TimeZone = .current) -> [Date] {
        let calendar = Calendar.current
        guard let days = calendar.dateComponents([.day], from: self, to: endDate).day else { return [] }
        var daysSet: Set<Date> = []
        let startOfDay = self.getStartOfDay(timeZone: timeZone)
        for i in (0 ... days) {
            guard let newDate = startOfDay.appendDays(days: i) else { continue }
            daysSet.insert(newDate)
        }
        let result = Array(daysSet).sorted {$0 < $1}
        return result
    }
    
    func getEndOfDay(timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        let startOfDay = getStartOfDay(timeZone: timeZone)
        let endOfDate = calendar.date(byAdding: .day, value: 1, to: startOfDay)
        return endOfDate?.addingTimeInterval(-1)
    }
    
    func getStartOfDay(timeZone: TimeZone = .current) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.startOfDay(for: self)
    }
    
    //it changes only the date components of the withNewDate (time part is staying without changing)
    func refineDate( withNewDate: Date, timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        let setOfComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        let withNewDateComponents = calendar.dateComponents(setOfComponents, from: withNewDate)
        calendar.timeZone = timeZone
        guard let newYearValue = withNewDateComponents.year, let newMonthValue = withNewDateComponents.month, let newDayValue = withNewDateComponents.day else { return nil }
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        components.day = newDayValue
        components.month = newMonthValue
        components.year = newYearValue
        return calendar.date(from: components)
    }
    
    //it changes only the time components of the withNewDate (date part is staying without changing)
    func refineTime(withNewTime: Date, timeZone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        let setOfComponents: Set<Calendar.Component> = [.hour, .minute, .second]
        let withNewTimeComponents = calendar.dateComponents(setOfComponents, from: withNewTime)
        return calendar.date(bySettingHour: withNewTimeComponents.hour ?? 0,
                             minute: withNewTimeComponents.minute ?? 0,
                             second: withNewTimeComponents.second ?? 0,
                             of: self)
    }
}

public struct DateIntervalIterator: IteratorProtocol {
    private let dateInterval: DateInterval
    private let calendar: Calendar
    private let calendarComponent: Calendar.Component
    
    private var multiplier = 0
    
    init(_ dateInterval: DateInterval, _ calendarComponent: Calendar.Component, _ calendar: Calendar) {
        self.dateInterval = dateInterval
        self.calendar = calendar
        self.calendarComponent = calendarComponent
    }
    
    public mutating func next() -> Date? {
        guard let start = self.calendar.date(byAdding: self.calendarComponent, value: multiplier, to: self.dateInterval.start),
            calendar.compare(start, to: dateInterval.end, toGranularity: .day) == ComparisonResult.orderedAscending else {
                return nil
        }
        multiplier += 1
        return start
    }
}

class IteratableDateInterval: Sequence {
    
    private let dateInterval: DateInterval
    private let calendarComponent: Calendar.Component
    private let calendar: Calendar
    
    init(_ dateInterval: DateInterval, _ calendarComponent: Calendar.Component = .day, _ calendar: Calendar = .current) {
        self.dateInterval = dateInterval
        self.calendar = calendar
        self.calendarComponent = calendarComponent
    }
    
    func makeIterator() -> DateIntervalIterator {
        return DateIntervalIterator(self.dateInterval, self.calendarComponent, self.calendar)
    }
}
