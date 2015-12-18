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
import RateLimit
class HealthKit : NSObject
{
    let storage = HKHealthStore()
    
    var objects = [PFObject]()
    var stop = false
    var stepIndex = 0
    var distanceIndex = 0
    var flightIndex = 0
    var inSync = false
    var batchStart : NSDate?
    var batchSaveRequests  = 0
    var recordType = RecordType.Step
    var isEnabled = false
    
    let CALLSPERSECOND = Int(20)
    override
    init()
    {
        super.init()
        checkAuthorization()
    }
    
    func checkAuthorization() -> Bool
    {
        // Default to assuming that we're authorized
       // isEnabled = true
        if isEnabled {
            return isEnabled
        }
        // Do we have access to HealthKit on this device?
        if HKHealthStore.isHealthDataAvailable()
        {
            // We have to request each data type explicitly
            let readTypes = NSSet(objects: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)! , HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)!)
            
            
            // Now we can request authorization for step count data
            storage.requestAuthorizationToShareTypes(nil, readTypes: readTypes as? Set<HKObjectType>) { (success, error) -> Void in
                self.isEnabled = success
            }
        }
        else
        {
            self.isEnabled = false
        }
        
        return isEnabled
    }
    /*
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
    */ //Remove
    
    func fillRecordArrays(){
        
    }
    func fillArray(startDate : NSDate, endDate :NSDate, recordType : RecordType , completion: ( NSError?) -> ()){
        var type : HKQuantityType
        var className : String
        var unit : HKUnit?
        switch recordType {
        case RecordType.Step:
            type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
            className = "Step"
            unit = HKUnit.countUnit()
            break
        case RecordType.Distance:
            type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!
            className = "Distance"
            unit = HKUnit.mileUnit()
            break
        case RecordType.Flight:
            type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)!
            className = "Flight"
            unit = HKUnit.countUnit()
            break
        case RecordType.None:
            return
        default:
            return
        }
        
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate , endDate: endDate, options: .None)
        
        // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
            var count: Double = 0
            
            if results?.count > 0
            {
                for result in results as! [HKQuantitySample]
                {
                    /*
                    
                    */
                    count += result.quantity.doubleValueForUnit(unit!)
                }
            }
            
            
            completion( error)
            if count > 0 {
                let record = PFObject(className:className)
                record["sampleType"] = className
                record["startDate"] = startDate
                record["endDate"] = endDate
                record["quantity"] = count
                record["User"] = PFUser.currentUser()
                self.objects += [record]
            }
        }
        storage.executeQuery(query)
    }
    func syncAll(completion: ( NSError?) -> ()){
      //  autoreleasepool({ () -> () in
        // The type of data we are requesting (this is redundant and could probably be an enumeration
            inSync = true;
       // let stepType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
       // let distanceType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
       // let flightsType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)
        backgroundThread(0.0, background: {
               self.startEmptyArraysWhenAvailable()
                
        })
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
                fillArray(startDate!, endDate: endDate!, recordType: RecordType.Step, completion : completion)
                fillArray(startDate!, endDate: endDate!, recordType: RecordType.Distance, completion : completion)
                fillArray(startDate!, endDate: endDate!, recordType: RecordType.Flight, completion : completion)
                
            }

            
         
            inSync = false
   // })
    
    }
    func updateTimer(timer: NSTimer) {
        print ("hello")
    }
    func startEmptyArraysWhenAvailable(){
        var query : PFQuery = PFQuery(className: "_User")
        query.whereKey("inSync", equalTo: true)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
             var readyToSync  = true
            if error == nil{
                if objects?.count > 0 {
                    readyToSync = false
                }
            }
            if readyToSync {
               //self.emptyArrays()
                
            }
        }
    }
    /*
    func emptyArrays(){
        PFUser.currentUser()?.setValue(true, forKey: "inSync")
        PFUser.currentUser()?.saveInBackground()
        while inSync == true ||  self.objects.count > 0 {
            
            RateLimit.execute(name: "saveObject", limit: 10){
                for index in 1...167 {
                var object : PFObject?
                if self.objects.count > 0 {
                    object = self.objects.popLast()
                }
                if object != nil{
                    object!.saveInBackgroundWithBlock({
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("Record saved")
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
                        
                    })
                }
            }
            }
        }
        
        
        PFUser.currentUser()?.setValue(false, forKey: "inSync")
        
        PFUser.currentUser()?.saveInBackground()
    }
    */
    
    /*
    func pushToParse(){
        let now = NSDate()
        var m = 0
        switch (recordType){
        case RecordType.None:
            
            PFUser.currentUser()?.setValue(now, forKey: "sycnedTo")
            stop = true
            break;
        case RecordType.Step:
            m = min(self.stepObjects.count-1 , self.stepIndex+self.CALLSPERSECOND)
            print(m)
            //backgroundThread(0.0, background: {
            PFObject.saveAllInBackground(Array(self.stepObjects[self.stepIndex...min(self.stepObjects.count-1 , self.stepIndex+self.CALLSPERSECOND)]), block: {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    print("Step Records saved")
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
                
            })
            //})
            stepIndex += CALLSPERSECOND
            if stepIndex+self.CALLSPERSECOND >= stepObjects.count{
                recordType = RecordType.Distance
            }
            break;
        case RecordType.Distance:
            // backgroundThread(0.0, background: {
            m = min(self.distanceObjects.count-1 , self.distanceIndex+self.CALLSPERSECOND)
            print(m)
            PFObject.saveAllInBackground(Array(self.distanceObjects[self.distanceIndex...min(self.distanceObjects.count-1 , self.distanceIndex+self.CALLSPERSECOND)]), block: {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    print("Distance Records saved")
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
                
            })
              //  })
            distanceIndex += CALLSPERSECOND
            if distanceIndex + self.CALLSPERSECOND >= distanceObjects.count{
                recordType = RecordType.Flight
            }
            break;
        case RecordType.Flight:
            
            //backgroundThread(0.0, background: {
            m = min(self.flightObjects.count-1 , self.flightIndex+self.CALLSPERSECOND)
            print(m)
                PFObject.saveAllInBackground(Array(self.flightObjects[self.flightIndex...min(self.flightObjects.count-1 , self.flightIndex+self.CALLSPERSECOND)]), block: {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        print("Flight Records saved")
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
                    
                })
                
           // })
            
            flightIndex += CALLSPERSECOND
            if flightIndex + self.CALLSPERSECOND >= flightObjects.count{
                recordType = RecordType.None
            }
            break;
        default:
            
            PFUser.currentUser()?.setValue(now, forKey: "sycnedTo")
            stop = true
            break;
        }
        

        // Save arrays to parse
        
      
        
        
    }
    */

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
enum RecordType{
    case Step
    case Flight
    case Distance
    case None
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

func backgroundThread(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
        if(background != nil){ background!(); }
        
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) {
            if(completion != nil){ completion!(); }
        }
    }
}