//
//  HealthKitManager.swift
//  Movement
//
//  Created by Zara Perumal on 12/28/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import HealthKit
import Parse
class HealthKitManager : NSObject
{
    let dateManager = DateManager()
    let queue = NSOperationQueue()
    var records = [healthRecord]()
    let storage = HKHealthStore()
    let beginningDate = NSDate(dateString:"2014-08-01")
    var remainingOps : Int64 = 0

    
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        // 1. Set the types you want to read from HK Store
        let readTypes = NSSet(objects: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)! , HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)!)
        
      
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError( domain: "ZaraPerumal.movement.healthkit" , code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        storage.requestAuthorizationToShareTypes(nil, readTypes: readTypes as? Set<HKObjectType>){ (success, error) -> Void in
            
            if( completion != nil )
            {
                completion(success:success,error:error)
            }
        }
    }
    
    func getRecords() -> [healthRecord] {
        return records
    }
    func fillRecords(completion: ( NSError?) -> ()){
        
        
        let syncedTo  = PFUser.currentUser()!.valueForKey("syncedTo")
        let now = dateManager.getDateHourRoudnedDown(NSDate())
        var beginning : NSDate
        if syncedTo == nil {
            beginning = NSDate(dateString:"2014-08-01")
        }else{
            beginning = syncedTo as! NSDate
        }
        
        let interval = NSDateComponents()
        interval.hour = 1
        
        let types = [HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount) , HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning), HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)]
        let units = [HKUnit.countUnit() , HKUnit.mileUnit(), HKUnit.countUnit()]
        let classes  = ["Step" , "Distance" , "Flight"]
        var leftToComplete = classes.count
        
        //let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        for i in 0...types.count-1 {
            let type  : HKQuantityType = types[i]!
            let unit : HKUnit? = units[i]
            let className : String = classes[i]
            let predicate = HKQuery.predicateForSamplesWithStartDate(beginning, endDate: now, options: .StrictStartDate)
            let query = HKStatisticsCollectionQuery(quantityType: type, quantitySamplePredicate: predicate, options: [.CumulativeSum], anchorDate: NSDate().beginningOfDay(), intervalComponents:interval)
            
            query.initialResultsHandler = { query, results, error in
                
                
                if let myResults = results{
                    
                    let hoursback = self.dateManager.hoursBack(now,past:  beginning)
                    for i in 0..<hoursback
                    {
                        let startDate = self.dateManager.getDateRoundedPlusHours(now ,hours:  0 - i)
                        let endDate = self.dateManager.getDateRoundedPlusHours(now, hours: 1-i)
                        myResults.enumerateStatisticsFromDate(startDate!, toDate: endDate!) {
                            statistics, stop in
                            
                            if let quantity = statistics.sumQuantity() {
                                
                                let date = statistics.startDate
                                let count = quantity.doubleValueForUnit(unit!)
                                self.records += [healthRecord(sampleType: className, startDate: startDate!, endDate: endDate!, quantity: count)]
                                
                            }
                        }
                    }
                    
                    
                }
                leftToComplete = leftToComplete - 1
                if leftToComplete == 0 {
                    
                    completion(nil)
                }
            }
            self.storage.executeQuery(query)
        }
        
    }
    struct healthRecord {
        var sampleType = String();
        var startDate = NSDate();
        var endDate = NSDate();
        var quantity = Double();
        static func jsonArray(array : [healthRecord]) -> String
        {
            return "[" + array.map {$0.jsonRepresentation}.joinWithSeparator(",") + "]"
        }
        var jsonRepresentation : String {
            return "{\"sampleType\":\"\(sampleType)\",\"startDate\":\"\(startDate)\",\"endDate\":\"\(endDate)\",\"quantity\":\"\(quantity)\"}"
        }
    
    }
    
}

extension NSDate {
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d = dateStringFormatter.dateFromString(dateString)!
        self.init(timeInterval:0, sinceDate:d)
    }
    func beginningOfDay() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: self)
        return calendar.dateFromComponents(components)!
    }
    
    func endOfDay() -> NSDate {
        let components = NSDateComponents()
        components.day = 1
        var date = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: self.beginningOfDay(), options: [])!
        date = date.dateByAddingTimeInterval(-1)
        return date
    }
}
func yesterDay() -> NSDate {
    
    let today: NSDate = NSDate()
    
    let daysToAdd:Int = -1
    
    // Set up date components
    let dateComponents: NSDateComponents = NSDateComponents()
    dateComponents.day = daysToAdd
    
    // Create a calendar
    let gregorianCalendar: NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    let yesterDayDate: NSDate = gregorianCalendar.dateByAddingComponents(dateComponents, toDate: today, options:NSCalendarOptions(rawValue: 0))!
    
    return yesterDayDate
}