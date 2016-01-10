//
//  DateUtilities.swift
//  Movement
//
//  Created by Zara Perumal on 12/29/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation

class DateManager :NSObject {
    func hoursBack(now : NSDate, past :NSDate) -> Int64{
        let elapsedTime = now.timeIntervalSinceDate(past)
        let duration = Int64(elapsedTime)
        let durationInHours = duration / 3600
        return durationInHours
    }
    
    func getDateHourRoudnedDown(date: NSDate) -> NSDate {
        
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Minute, .Hour, .Day , .Month, .Year ], fromDate: date)
        return  calendar.dateBySettingUnit(.Minute, value: 0, ofDate: date, options: NSCalendarOptions(rawValue: 0)  )!
    }
    func getDateRoundedPlusHours(date: NSDate, hours: Int) -> NSDate?{
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let roundedDate : NSDate = getDateHourRoudnedDown(date)
        let components = calendar.components([.Minute, .Hour, .Day , .Month, .Year ], fromDate: roundedDate)
        return calendar.dateByAddingUnit(.Hour, value: hours, toDate: roundedDate, options: NSCalendarOptions(rawValue: 0))
        
    }
}