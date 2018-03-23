//
//  CalendarMonthEventViewModel.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/22/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import Foundation
import UIKit

class CalendarMonthEventViewModel {
    
    private(set) var uid: String?
    private(set) var titleText: String = ""
    private(set) var textColor: UIColor = UIColor.black
    private(set) var borderColor: UIColor = UIColor.clear
    private(set) var backGroundColor: UIColor = UIColor.white
    private(set) var accountTypeImage: UIImage?
    private(set) var eventTypeImage: UIImage?
    
    func setupData(eventModel: CalendarEvents) {
        switch eventModel {
            case .callEvent(let eventCall):
                self.titleText = eventCall.accountName
                borderColor = UIColor.blue
                backGroundColor = UIColor.cyan
                accountTypeImage = UIImage(named: "EventType")
                eventTypeImage = UIImage(named: "EventType")
            case .generalEvent(let generalEvent):
                self.titleText = generalEvent.name
                borderColor = UIColor.blue
                backGroundColor = UIColor.cyan
                accountTypeImage = UIImage(named: "EventType")
                eventTypeImage = UIImage(named: "EventType")
            case .totEvent(let totEvent):
                self.titleText = totEvent.type
                borderColor = UIColor.blue
                backGroundColor = UIColor.cyan
                accountTypeImage = UIImage(named: "EventType")
                eventTypeImage = UIImage(named: "EventType")
        }
        self.uid = eventModel.uid
    }
}
