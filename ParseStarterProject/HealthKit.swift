//
//  HealthManager.swift
//  Movement
//
//  Created by Zara Perumal on 11/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//
import Foundation
import HealthKit
import Parse
class HealthKit
{
    let storage = HKHealthStore()
    
    init()
    {
        checkAuthorization()
    }
    
    func checkAuthorization() -> Bool
    {
        // Default to assuming that we're authorized
        var isEnabled = true
        
        // Do we have access to HealthKit on this device?
        if HKHealthStore.isHealthDataAvailable()
        {
            // We have to request each data type explicitly
            let steps = NSSet(object: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!)
            
            // Now we can request authorization for step count data
            storage.requestAuthorizationToShareTypes(nil, readTypes: steps as? Set<HKObjectType>) { (success, error) -> Void in
                isEnabled = success
            }
        }
        else
        {
            isEnabled = false
        }
        
        return isEnabled
    }
    
    func lastDaysSteps(completion: ( NSError?) -> () )
    {
        // The type of data we are requesting (this is redundant and could probably be an enumeration
        let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        // Our search predicate which will fetch data from now until a day ago
        // (Note, 1.day comes from an extension
        // You'll want to change that to your own NSDate
        let hoursback = 24
        for i in 0 ... hoursback {
        let now = NSDate()
            let startDate = getDateRoundedPlusHours(now ,hours:  0 - i)
            let endDate = getDateRoundedPlusHours(now, hours: 1-i)
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate , endDate: endDate, options: .None)
        
        // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
        let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
            var steps: Double = 0
            
            if results?.count > 0
            {
                for result in results as! [HKQuantitySample]
                {
                    /*
                    
                    */
                    steps += result.quantity.doubleValueForUnit(HKUnit.countUnit())
                }
            }
            
            
            completion( error)
            let stepRecord = PFObject(className:"Step")
            stepRecord["sampleType"] = "Step"
            stepRecord["startDate"] = startDate
            stepRecord["endDate"] = endDate
            stepRecord["quantity"] = steps
            stepRecord["User"] = PFUser.currentUser()
            stepRecord.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    print("Step Record saved")
                } else {
                    // There was a problem, check error.description
                    //print(error?.description)
                }
            }
        }
            
        
        storage.executeQuery(query)
        }
    }
    
    func syncAll(completion: ( NSError?) -> ()){
        
        // The type of data we are requesting (this is redundant and could probably be an enumeration
        let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        // Our search predicate which will fetch data from now until a day ago
        // (Note, 1.day comes from an extension
        // You'll want to change that to your own NSDate
        let syncedTo  = PFUser.currentUser()!.valueForKey("syncedTo")
        let now = NSDate()
        var beginning : NSDate
        if syncedTo == nil {
             beginning = NSDate(dateString:"2014-08-01")
             //beginning = now.dateByAddingTimeInterval(NSTimeInterval(-3600 * 24 * 7 * 4 * 3))
        }else{
             beginning = syncedTo as! NSDate
        }
        let hoursback = hoursBack(now,past:  beginning)
            for i in 0 ... hoursback {
                
                let startDate = getDateRoundedPlusHours(now ,hours:  0 - i)
                let endDate = getDateRoundedPlusHours(now, hours: 1-i)
                let predicate = HKQuery.predicateForSamplesWithStartDate(startDate , endDate: endDate, options: .None)
                
                // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
                let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
                    var steps: Double = 0
                    
                    if results?.count > 0
                    {
                        for result in results as! [HKQuantitySample]
                        {
                            /*
                            
                            */
                            steps += result.quantity.doubleValueForUnit(HKUnit.countUnit())
                        }
                    }
                    
                    
                    completion( error)
                    if steps > 0 {
                    let stepRecord = PFObject(className:"Step")
                    stepRecord["sampleType"] = "Step"
                    stepRecord["startDate"] = startDate
                    stepRecord["endDate"] = endDate
                    stepRecord["quantity"] = steps
                    stepRecord["User"] = PFUser.currentUser()
                    stepRecord.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("Step Record saved")
                        } else {
                            // There was a problem, check error.description
                            print(error?.description)
                            switch(error!.code){
                            case 209:
                                sleep(1)
                                break
                            default :
                                break
                            }
                        }
                    }
                    }
                }
                
                
                storage.executeQuery(query)
            }
        PFUser.currentUser()?.setValue(now, forKey: "sycnedTo")
      

        
    }

    func hoursBack(now : NSDate, past :NSDate) -> Int64{
        let elapsedTime = now.timeIntervalSinceDate(past)
        let duration = Int64(elapsedTime)
        let durationInHours = duration / 3600
        return durationInHours
    }
    func getThisPersonsStartDate(){
        
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

extension NSDate
{
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d = dateStringFormatter.dateFromString(dateString)!
        self.init(timeInterval:0, sinceDate:d)
    }
}