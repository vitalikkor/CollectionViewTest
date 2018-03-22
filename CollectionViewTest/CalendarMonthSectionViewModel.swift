//
//  CalendarMonthSectionViewModel.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/22/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import Foundation
import UIKit

class CalendarMonthSectionViewModel {
    private(set) var dateInterval: DateInterval?
    private(set) var dateFormatter: DateFormatter?
    private(set) var selectedMonthInterval: DateInterval?
    private(set) var numberOfHiddenItemsPerDay: [Date:Int] = [:]
    
    init(dateInterval: DateInterval, selectedMonthInterval: DateInterval, dateFormatter: DateFormatter, numberOfHidenItemsPerDay: [Date:Int]) {
        self.dateInterval = dateInterval
        self.dateFormatter = dateFormatter
        self.selectedMonthInterval = selectedMonthInterval
        self.numberOfHiddenItemsPerDay = numberOfHidenItemsPerDay

    }
}
