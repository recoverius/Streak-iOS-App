////
////  Friends.swift
////  Streak
////
////  Created by Ilya Golubev on 21/09/2024.
////
//
//
//import Foundation
//
//enum FriendStatus: String, Codable {
//    case pending
//    case accepted
//    case rejected
//}
//
//struct Friend: Identifiable, Codable {
//    let id: UUID
//    var name: String
//    var phoneNumber: String
//    var achievements: [Achievement]
//    var calendarEntries: [CalendarEntry]
//    var status: FriendStatus
//    
//    init(id: UUID, name: String, phoneNumber: String, status: FriendStatus = .pending, achievements: [Achievement] = [], calendarEntries: [CalendarEntry] = []) {
//        self.id = id
//        self.name = name
//        self.phoneNumber = phoneNumber
//        self.status = status
//        self.achievements = achievements
//        self.calendarEntries = calendarEntries
//    }
//    
//    init(cdFriend: CDFriend) {
//        self.id = cdFriend.id
//        self.name = cdFriend.name
//        self.phoneNumber = cdFriend.phoneNumber
//        self.status = FriendStatus(rawValue: cdFriend.status) ?? .pending
//        self.achievements = cdFriend.achievementsArray.map { Achievement(cdAchievement: $0) }
//        self.calendarEntries = cdFriend.calendarEntriesArray.map { CalendarEntry(cdEntry: $0) }
//    }
//}
//
//struct CalendarEntry: Identifiable, Codable {
//    let id: UUID
//    var date: Date
//    var tracker: Tracker
//    
//    init(cdEntry: CDCalendarEntry) {
//        self.id = cdEntry.id
//        self.date = cdEntry.date
//        self.tracker = Tracker(cdTracker: cdEntry.tracker!)
//    }
//}
