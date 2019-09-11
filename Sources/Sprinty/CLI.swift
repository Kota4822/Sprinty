//
//  CLI.swift
//  Sprinty
//
//  Created by takumi-karibe on 2019/09/11.
//

import Foundation
import SwiftyAtlassian
import SwiftyJIRA

public struct JiraSprintCLI {
    
    /// run
    ///
    /// - Parameter args: [Key:Value] string array
    public static func run() {
        SprintGenerator.generate()
    }
}

enum Weekday: Int {
    case sun = 1
    case mon
    case tue
    case wed
    case thu
    case fri
    case sat
}

enum BoardType: CaseIterable {
    case test
    
    var id: String {
        switch self {
        case .test:
            return "111"
        }
    }
    
    var sprintPrefix: String {
        switch self {
        case .test:
            return "hoge"
        }
    }
}

public struct SprintGenerator {
    
    private init() {}
    
    public static func generate() {
        BoardType.allCases.forEach {
            generate(for: $0)
        }
    }
    
    private static func generate(for board: BoardType) {
        
        let name = sprintName(for: board)
        print(name)
        
        let result = Atlassian<Server>.JiraSoftware.Sprint().create(name: name, boardID: board.id, dateRange: nil/*(start: Date, end: Date)?*/)
    }
    
    private static func sprintName(for board: BoardType) -> String {
        
        guard let nextMonday = nextWeekDate(for: .mon) else {
            fatalError("⛔️ 日時取得失敗")
        }
        
        let cal = Calendar(identifier: .gregorian)
        var components = cal.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second, .nanosecond], from: nextMonday)
        let day = components.day!
        components.day = day + 4
        guard let nextFriday = cal.date(from: components) else {
            fatalError("⛔️ 日時取得失敗")
        }
        
        return board.sprintPrefix + "_" + nextMonday.string + "~" + nextFriday.string
    }
    
    private static func nextWeekDate(for weekday: Weekday) -> Date? {
        
        let date = Date()
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second, .nanosecond], from: date)
        guard let weekdayValue = components.weekday else {
            return nil
        }
        
        let targetWeekdayValue = weekday.rawValue
        let diff = targetWeekdayValue - weekdayValue
        let addDay = diff < 0 ? diff + 7 : diff
        
        var fixComponents : DateComponents = DateComponents()
        // 計算した日付を足して、次の曜日が来る日に調整
        fixComponents.day = addDay
        
        return calendar.date(byAdding: fixComponents, to: date)
    }
}

private extension Date {
    var string: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: self)
    }
}
