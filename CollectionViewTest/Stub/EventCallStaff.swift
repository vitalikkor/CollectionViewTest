//
//  EventCallStaff.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/14/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import Foundation

protocol CalendarEvent {
    var uid: String { get }
    var dateInterval: DateInterval { get }
    var isAllDay: Bool { get }
}

struct CalendarEventCall: CalendarEvent {
    // MARK: - CalendarEvent protocol properties
    let uid: String
    let dateInterval: DateInterval
    let isAllDay: Bool = false
    // other specific properties
    let channel: CallChannel
    let accountName: String
    let accountId: String?
    let status: OCEDBCallStatus
    let signature: String?
    let submissionDate: Date?
}

extension CalendarEventCall: Hashable, Equatable {
    var hashValue: Int {
        return uid.hashValue
    }
    
    static func ==(lhs: CalendarEventCall, rhs: CalendarEventCall) -> Bool {
        return lhs.uid == rhs.uid
    }
}

enum CallChannel: String, Codable {
    case faceToFace = "Face To Face"
    case phone = "Phone"
    case fax = "Fax"
    case email = "Email"
    case remote = "Remote"
    case empty = ""
}

enum OCEDBCallStatus: String, Codable {
    
    case empty = "empty"
    
    case submited = "Submitted"
    
    case draft = "Draft"
    
    case withdrawn = "Withdrawn"
}
